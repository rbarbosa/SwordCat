//
//  CatBreedsViewModel.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import CasePaths
import Foundation
import struct SwiftUI.Binding

// TODO: - Move this to Models
struct Pagination {
    var hasMoreItems: Bool = true
    var limit: Int = 10
    var nextPage: Int = 0
    var thresholdItemId: String?
}

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
    }

    // MARK: - Action

    enum Action {
        case breedCardTapped(Breed)
        case favoriteButtonTapped(Breed)
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
        case .breedCardTapped(let breed):
            let isFavorite = state.isFavorite(breed)
            let viewModel = CatBreedDetailViewModel(
                initialState: .init(
                    breed: breed,
                    isFavorite: isFavorite
                ),
                favoritesManager: favoritesManager
            )
            state.destination = .detail(viewModel)

        case .favoriteButtonTapped(let breed):
            handleFavoriteTapped(breed)

        case .search(let query):
            state.isSearching = !query.isEmpty
            search(query.lowercased())


        case .onAppear:
            if state.didFirstAppear {
                return
            }
            state.didFirstAppear = true
            fetchBreeds(page: 0)

        case .onCardBreedAppear(let breed):
            print("Card breed \(breed.name) appeared")
            handleItemAppeared(breed)
        }
    }

    private func fetchBreeds(page: Int) {
        state.isLoading = true
        Task {
            do {
                let response = try await repository.fetchBreeds(page)

                // This should only be needed once... confirm
                let favoriteImageIds = await favoritesManager.favoriteImageIds
                state.favoriteBreedIds = .init(favoriteImageIds.keys)

                state.isLoading = false
                state.fetchedBreeds.append(contentsOf: response.breeds)

                state.pagination.hasMoreItems = response.breeds.count > 0
                if state.pagination.hasMoreItems {
                    state.pagination.nextPage += 1
                    state.updateThresholdItemId()
                } else {
                    state.pagination.thresholdItemId = nil
                }
            } catch {
                state.isLoading = false
                // If the fetch failed for first page, and while we don't have a button to retry, let's enable
                // fetch for next page
                if state.pagination.nextPage == 0 {
                    state.didFirstAppear = false
                }
                print("Got error fetching breeds: \(error)")
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
