//
//  CatBreedFavoritesViewModel.swift
//  SwordCat
//
//  Created by Rui Barbosa on 22/11/2024.
//

import Foundation



/*
 To get the favorites:
    A - The favorites are injected
    B1 - We fetch the favorites -> get image_ids
    B2 - We fetch images -> get breeds
 */

@Observable
final class CatBreedFavoritesViewModel {

    // MARK: - Destination

    enum Destination {
    }

    // MARK: - State

    struct State {
        var isLoading: Bool = false
        var favorites: [Breed] = []
        var favoritesFetched: [FavoriteBreed] // Rename to just favorites
        let user: User = .init()
    }

    // MARK: - Action

    enum Action {
        case onAppear
    }

    private(set) var state: State
    private let repository: CatBreedsRepository

    // MARK: - Initialization

    init(
        initialState: State,
        repository: CatBreedsRepository
    ) {
        self.state = initialState
        self.repository = repository
    }

    func send(_ action: Action) {
        switch action {
        case .onAppear:
            fetchFavorites()
        }
    }

    // MARK: - Private methods

    func fetchFavorites() {
        state.isLoading = true
        Task {
            defer {
                state.isLoading = false
            }

            do {
                let response = try await repository.fetchFavorites(state.user.id)

                var newFavorites: [FavoriteBreed] = []
                if state.favoritesFetched.isEmpty {
                    newFavorites = response.favorites
                } else {
                    newFavorites = response.favorites.filter { new in
                        !state.favoritesFetched.contains(where: { $0.id == new.id })
                    }
                }

                for favorite in newFavorites {
                    let response = try await repository.fetchImage(favorite.imageId)
                    state.favorites.append(response.breed)
                }

                state.favoritesFetched.append(contentsOf: newFavorites)
            } catch {
                print("Error fetching favorites: \(error.localizedDescription)")
            }
        }
    }
}
