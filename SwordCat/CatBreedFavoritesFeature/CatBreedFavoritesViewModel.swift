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


/*
 To get the favorites:
    A - The favorites are injected
    B1 - We fetch the favorites -> get image_ids
    B2 - We fetch images -> get breeds
 */

@Observable
final class CatBreedFavoritesViewModel {

    // MARK: - Destination

    @CasePathable
    enum Destination {
        case detail(CatBreedDetailViewModel.State)
    }

    // MARK: - State

    struct State {
        var destination: Destination?
        var isLoading: Bool = false
        var favorites: IdentifiedArrayOf<Breed> = []
        var favoritesFetched: [FavoriteBreed] // Rename to just favorites
        let user: User = .init()

        fileprivate var didInitialFetch: Bool = false
    }

    // MARK: - Action

    enum Action {
        case addFavorite(Breed)
        case breedCardTapped(Breed)
        case onAppear
        case removeFavorite(Breed)
    }

    private(set) var state: State
    private let repository: CatBreedsRepository
    private var favoritesManager: FavoritesManager

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
            state.favorites.insert(breed, at: 0)

        case .breedCardTapped(let breed):
            let detailState = CatBreedDetailViewModel.State(breed: breed, isFavorite: true)
            state.destination = .detail(detailState)

        case .onAppear:
            if !state.didInitialFetch {
                state.didInitialFetch = true
                fetchFavoriteBreeds()
                return
            }

        case .removeFavorite(let breed):
            state.favorites.remove(id: breed.id)
        }
    }

    // MARK: - Private methods

    private func fetchFavoriteBreeds() {
        state.isLoading = true

        Task {
            defer {
                state.isLoading = false
            }
            
            do {
                state.favorites = try await favoritesManager.fetchFavoriteBreeds()
            } catch {
                state.didInitialFetch = false
                print("Error fetching favorites: \(error.localizedDescription)")
            }
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
