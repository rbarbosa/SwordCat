//
//  CatBreedsViewModel.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import CasePaths
import Foundation
import struct SwiftUI.Binding
import class UIKit.UIImage

@Observable
@dynamicMemberLookup
final class CatBreedsViewModel {

    // MARK: - Destination

    @CasePathable
    enum Destination {
        case detail(CatBreedDetailViewModel)
    }

    // MARK: - State

    struct State {
        var breeds: [Breed] {
            isSearching ? filteredBreeds : fetchedBreeds
        }
        var destination: Destination?
        var hasFetchingError: Bool = false
        var isLoading: Bool = false
        var isSearching: Bool = false
        var favoriteBreedIds: Set<String> = []
        var pagination: Pagination = .init()
        let user: User = .init()

        fileprivate var didFirstAppear: Bool = false
        fileprivate var fetchedBreeds: [Breed] = []
        fileprivate var filteredBreeds: [Breed] = []
        fileprivate var updatingFavoriteBreedIds: Set<String> = []
        fileprivate var errorFavoriteBreedIds: Set<String> = []
        fileprivate var imageStates: [String: ImageState] = [:]

        mutating func updateThresholdItemId() {
            let index = breeds.count - 3
            guard index > 0 else { return }

            pagination.thresholdItemId = breeds[index].id
        }

        func isFavorite(_ breed: Breed) -> Bool {
            favoriteBreedIds.contains(breed.referenceImageId)
        }

        func isUpdatingFavoriteBreed(_ breed: Breed) -> Bool {
            updatingFavoriteBreedIds.contains(breed.id)
        }

        func hasErrorFavoriteBreed(_ breed: Breed) -> Bool {
            errorFavoriteBreedIds.contains(breed.id)
        }

        func imageState(for breed: Breed) -> ImageState {
            imageStates[breed.id] ?? .loading
        }
    }

    // MARK: - Action

    enum Action {
        case breedCardAppeared(Breed)
        case breedCardTapped(Breed)
        case detailBreedAction(CatBreedDetailViewModel.Action.Delegate)
        case favoriteButtonTapped(Breed)
        case retryButtonTapped
        case search(String)
        case onAppear
        case onCardBreedAppear(Breed)

        enum Delegate {
            case didFavorite(Breed)
            case didUnfavorite(Breed)
        }
    }

    private enum Constants {
        static let fetchLimit: Int = 10
    }

    // MARK: - Properties

    private(set) var state: State
    private let repository: CatBreedsRepository
    private var favoritesManager: FavoritesManager
    let parentActionHandler: (Action.Delegate) -> Void
    private let imageCache: ImageCache = .shared

    // MARK: - Initialization

    init(
        initialState: State,
        repository: CatBreedsRepository,
        favoritesManager: FavoritesManager,
        parentActionHandler: @escaping (Action.Delegate) -> Void
    ) {
        self.state = initialState
        self.repository = repository
        self.favoritesManager = favoritesManager
        self.parentActionHandler = parentActionHandler
    }

    func send(_ action: Action) {
        switch action {
        case .breedCardAppeared(let breed):
            handleBreedCardAppeared(breed)

        case .breedCardTapped(let breed):
            let isFavorite = state.isFavorite(breed)
            let viewModel = CatBreedDetailViewModel(
                initialState: .init(
                    breed: breed,
                    isFavorite: isFavorite
                ),
                favoritesManager: favoritesManager,
                parentActionHandler: { [weak self] in
                    self?.send(.detailBreedAction($0))
                }
            )
            state.destination = .detail(viewModel)

        case .detailBreedAction(let delegateAction):
            handleBreedDetailDelegateAction(delegateAction)

        case .favoriteButtonTapped(let breed):
            handleFavoriteTapped(breed)

        case .retryButtonTapped:
            fetchBreeds(page: state.pagination.nextPage)

        case .search(let query):
            state.isSearching = !query.isEmpty
            search(query.lowercased())


        case .onAppear:
            if state.didFirstAppear {
                updateFavoritesState()
                return
            }
            
            state.didFirstAppear = true
            fetchBreeds(page: 0)

        case .onCardBreedAppear(let breed):
            handleItemAppeared(breed)
        }
    }

    private func fetchBreeds(page: Int) {
        state.isLoading = true

        Task {
            defer {
                state.isLoading = false
            }

            do {
                let response = try await repository.fetchBreeds(page)

                // This should only be needed once... confirm
                let favoriteImageIds = await favoritesManager.favoriteImageIds
                state.favoriteBreedIds = .init(favoriteImageIds.keys)

                state.fetchedBreeds.append(contentsOf: response.breeds)

                state.pagination.hasMoreItems = response.breeds.count > 0
                if state.pagination.hasMoreItems {
                    state.pagination.nextPage += 1
                    state.updateThresholdItemId()
                } else {
                    state.pagination.thresholdItemId = nil
                }
                state.hasFetchingError = false
            } catch {
                state.hasFetchingError = true
            }
        }
    }

    private func handleItemAppeared(_ breed: Breed) {
        guard
            state.pagination.hasMoreItems,
            let thresholdItemId = state.pagination.thresholdItemId,
            breed.id == thresholdItemId
        else {
            return
        }

        fetchBreeds(page: state.pagination.nextPage)
    }

    private func handleFavoriteTapped(_ breed: Breed) {
        state.updatingFavoriteBreedIds.insert(breed.id)
        state.errorFavoriteBreedIds.remove(breed.id)

        if state.favoriteBreedIds.contains(breed.referenceImageId) {
            markBreedAsUnfavorite(breed)
        } else {
            markBreedAsFavorite(breed)
        }
    }

    private func markBreedAsFavorite(_ breed: Breed) {
        Task {
            let success = await favoritesManager.addFavorite(breed)
            state.updatingFavoriteBreedIds.remove(breed.id)
            if success {
                state.favoriteBreedIds.insert(breed.referenceImageId)
                parentActionHandler(.didFavorite(breed))
            } else {
                state.errorFavoriteBreedIds.insert(breed.id)
            }
        }
    }

    private func markBreedAsUnfavorite(_ breed: Breed) {
        Task {
            let success = await favoritesManager.removeFavorite(breed)
            state.updatingFavoriteBreedIds.remove(breed.id)
            if success {
                state.favoriteBreedIds.remove(breed.referenceImageId)
                parentActionHandler(.didUnfavorite(breed))
            } else {
                state.errorFavoriteBreedIds.insert(breed.id)
            }
        }
    }

    private func search(_ query: String) {
        // Search first within the items already fetched
        guard !state.fetchedBreeds.isEmpty else {
            searchBreed(query)
            return
        }

        let predicate = #Predicate<Breed> {
            $0.name.localizedStandardContains(query)
        }

        let filteredBreeds = try? state.fetchedBreeds.filter(predicate)

        if let filteredBreeds, !filteredBreeds.isEmpty {
            state.filteredBreeds = filteredBreeds
            return
        }

        // Not found breed within fetched breeds, search with API
        searchBreed(query)
    }

    private func searchBreed(_ withQuery: String) {
        state.isLoading = true
        Task {
            do {
                let response = try await repository.searchBreeds(withQuery)
                state.filteredBreeds = response.breeds
                state.isLoading = false
            } catch {
                state.isLoading = false
                print("Error searching breeds: \(error.localizedDescription)")
            }
        }
    }

    private func updateFavoritesState() {
        Task {
            let favoriteImageIds = await favoritesManager.favoriteImageIds
            state.favoriteBreedIds = .init(favoriteImageIds.keys)
        }
    }

    private func handleBreedDetailDelegateAction(_ action: CatBreedDetailViewModel.Action.Delegate) {
        switch action {
        case .didDismiss(_, let newFavoriteState):
            guard let _ = newFavoriteState else { return }

            updateFavoritesState()
        }
    }

    private func handleBreedCardAppeared(_ breed: Breed) {
        if let imageState = state.imageStates[breed.id] {
            switch imageState {
            case .loaded: return
            case .loading: return
            case .error: break
            }
        }

        Task {
            await loadImage(for: breed)
        }
    }

    private func loadImage(for breed: Breed) async {
        if let image = await imageCache.image(for: breed.url) {
            state.imageStates[breed.id] = .loaded(image)
            return
        }

        state.imageStates[breed.id] = .loading

        do {
            let (data, _) = try await URLSession.shared.data(from: breed.url)
            if let image = UIImage(data: data) {
                await imageCache.setImage(image, for: breed.url)
                state.imageStates[breed.id] = .loaded(image)
            } else {
                state.imageStates[breed.id] = .error
            }
        } catch {
            state.imageStates[breed.id] = .error
        }
    }
}

extension CatBreedsViewModel {
    func destinationBinding<Case>(
        for casePath: CaseKeyPath<Destination, Case>
    ) -> Binding<Case?> {
        Binding(
            get: { self.state.destination?[case: casePath] },
            set: { [weak self] newValue in
                guard let self else { return }
                if let newValue = newValue {
                    let destination = AnyCasePath(casePath).embed(newValue)
                    state.destination = destination
                } else {
                    state.destination = nil
                }
            }
        )
    }
}

extension CatBreedsViewModel {
    subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        get { state[keyPath: keyPath] }
    }
}
