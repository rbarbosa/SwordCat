//
//  CatBreedFavoritesViewModel.swift
//  SwordCat
//
//  Created by Rui Barbosa on 22/11/2024.
//

import CasePaths
import Foundation
import IdentifiedCollections
import struct SwiftUI.Binding
import SwiftUICore
import class UIKit.UIImage


/*
 To get the favorites:
    A - The favorites are injected
    B1 - We fetch the favorites -> get image_ids
    B2 - We fetch images -> get breeds
 */

enum ImageState {
    case loading
    case loaded(UIImage)
    case error
}

@Observable
final class CatBreedFavoritesViewModel {

    // MARK: - Destination

    @CasePathable
    enum Destination {
        case detail(CatBreedDetailViewModel)
    }

    // MARK: - State

    struct State {
        var destination: Destination?
        var isLoading: Bool = false
        var favorites: IdentifiedArrayOf<Breed> = []
        let user: User = .init()

        fileprivate var imageStates: [String: ImageState] = [:]
        fileprivate var didInitialFetch: Bool = false

        func imageState(for breed: Breed) -> ImageState {
            imageStates[breed.id] ?? .loading
        }
    }

    // MARK: - Action

    enum Action {
        case addFavorite(Breed)
        case breedCardAppeared(Breed)
        case breedCardTapped(Breed)
        case detailBreedAction(CatBreedDetailViewModel.Action.Delegate)
        case onAppear
        case removeFavorite(Breed)
    }

    private(set) var state: State
    private let repository: CatBreedsRepository
    private var favoritesManager: FavoritesManager
    private let imageCache: ImageCache = .shared

    // MARK: - Initialization

    init(
        initialState: State,
        repository: CatBreedsRepository,
        favoritesManager: FavoritesManager
    ) {
        self.state = initialState
        self.repository = repository
        self.favoritesManager = favoritesManager
    }

    func send(_ action: Action) {
        switch action {
        case .addFavorite(let breed):
            _ = withAnimation(.easeIn) {
                state.favorites.insert(breed, at: 0)
            }

        case .breedCardAppeared(let breed):
            handleBreedCardAppeared(breed)

        case .breedCardTapped(let breed):
            let viewModel = CatBreedDetailViewModel(
                initialState: .init(
                    breed: breed,
                    isFavorite: true
                ),
                favoritesManager: favoritesManager,
                parentActionHandler: { [weak self] in
                    self?.send(.detailBreedAction($0))
                }
            )
            state.destination = .detail(viewModel)

        case .detailBreedAction(let delegateAction):
            handleBreedDetailDelegateAction(delegateAction)

        case .onAppear:
            if !state.didInitialFetch {
                state.didInitialFetch = true
                fetchFavoriteBreeds()
                return
            }

        case .removeFavorite(let breed):
            _ = withAnimation(.easeOut) {
                state.favorites.remove(id: breed.id)
            }
        }
    }

    // MARK: - Private methods

    private func fetchFavoriteBreeds() {
        state.isLoading = true

        Task { @MainActor in
            defer {
                state.isLoading = false
            }
            
            do {
                state.favorites = try await favoritesManager.fetchFavoriteBreeds()
            } catch {
                state.didInitialFetch = false
            }
        }
    }

    private func handleBreedDetailDelegateAction(_ action: CatBreedDetailViewModel.Action.Delegate) {
        switch action {
        case .didDismiss(let breed, let newFavoriteState):
            guard let newFavoriteState else { return }
            let isFavorite = newFavoriteState
            if isFavorite {
                // This shouldn't happen...
                send(.addFavorite(breed))
            } else {
                self.send(.removeFavorite(breed))
            }
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

    @MainActor
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

extension CatBreedFavoritesViewModel {
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

extension CatBreedFavoritesViewModel {
    subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        get { state[keyPath: keyPath] }
    }
}
