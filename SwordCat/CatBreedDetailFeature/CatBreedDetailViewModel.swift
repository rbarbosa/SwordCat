//
//  CatBreedDetailViewModel.swift
//  SwordCat
//
//  Created by Rui Barbosa on 23/11/2024.
//

import Foundation
import class UIKit.UIImage

@Observable
final class CatBreedDetailViewModel: Identifiable {

    // MARK: - State

    struct State: Identifiable {
        let breed: Breed
        var isFavorite: Bool
        var isUpdating: Bool = false
        var hasErrorUpdating: Bool = false

        var id: String { breed.id }

        fileprivate var initialFavoriteState: Bool

        init(
            breed: Breed,
            isFavorite: Bool
        ) {
            self.breed = breed
            self.isFavorite = isFavorite
            self.initialFavoriteState = isFavorite
        }

        func image() async -> UIImage? {
            await ImageCache.shared.image(for: breed.url)
        }
    }

    // MARK: - Action

    enum Action {
        case onDisappear
        case toggleFavorite

        enum Delegate {
            case didDismiss(breed: Breed, newFavoriteState: Bool?)
        }
    }

    private(set) var state: State
    private var favoritesManager: FavoritesManager
    let parentActionHandler: (Action.Delegate) -> Void

    // MARK: - Initialization

    init(
        initialState: State,
        favoritesManager: FavoritesManager,
        parentActionHandler: @escaping (Action.Delegate) -> Void
    ) {
        self.state = initialState
        self.favoritesManager = favoritesManager
        self.parentActionHandler = parentActionHandler
    }

    func send(_ action: Action) {
        switch action {
        case .onDisappear:
            let isNewState = state.isFavorite != state.initialFavoriteState ? state.isFavorite : nil
            parentActionHandler(
                .didDismiss(breed: state.breed, newFavoriteState: isNewState)
            )

        case .toggleFavorite:
            state.isUpdating = true
            if state.isFavorite {
                markBreedAsUnfavorite(state.breed)
            } else {
                markBreedAsFavorite(state.breed)
            }
        }
    }

    // MARK: - Private methods

    private func markBreedAsUnfavorite(_ breed: Breed) {
        Task { @MainActor in
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
        Task { @MainActor in
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
