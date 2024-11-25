//
//  CatBreedDetailViewModel.swift
//  SwordCat
//
//  Created by Rui Barbosa on 23/11/2024.
//

import Foundation

@Observable
final class CatBreedDetailViewModel: Identifiable {

    // MARK: - Destination

    enum Destination {
    }

    // MARK: - State

    struct State: Identifiable {
        let breed: Breed
        var isFavorite: Bool
        var isUpdating: Bool = false
        var hasErrorUpdating: Bool = false

        var id: String { breed.id }
    }

    // MARK: - Action

    enum Action {
        case toggleFavorite
    }

    private(set) var state: State
    private var favoritesManager: FavoritesManager

    // MARK: - Initialization

    init(
        initialState: State,
        favoritesManager: FavoritesManager
    ) {
        self.state = initialState
        self.favoritesManager = favoritesManager
    }

    func send(_ action: Action) {
        switch action {
        case .toggleFavorite:
            state.isUpdating = true
            if state.isFavorite {
                markBreedAsUnfavorite(state.breed)
            } else {
                markBreedAsFavorite(state.breed)
            }
        }
    }

    private func markBreedAsUnfavorite(_ breed: Breed) {
        Task {
            defer {
                state.isUpdating = false
            }

            let success = await favoritesManager.removeFavorite(breed)
            if success {
                state.isFavorite = false
                state.hasErrorUpdating = false
            } else {
                state.hasErrorUpdating = true
            }
        }
    }

    private func markBreedAsFavorite(_ breed: Breed) {
        Task {
            defer {
                state.isUpdating = false
            }

            let success = await favoritesManager.addFavorite(breed)
            if success {
                state.isFavorite = true
                state.hasErrorUpdating = false
            } else {
                state.hasErrorUpdating = true
            }
        }
    }
}
