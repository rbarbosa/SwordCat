//
//  AppViewModel.swift
//  SwordCat
//
//  Created by Rui Barbosa on 24/11/2024.
//

import Foundation

@Observable
final class AppViewModel {

    // MARK: - State

    struct State {
        var breeds: CatBreedsViewModel.State
        var favorites: CatBreedFavoritesViewModel.State
        var isLoading: Bool = true
    }

    // MARK: - Action

    enum Action {
        case onAppear
    }

    // MARK: - Properties

    private(set) var breedsViewModel: CatBreedsViewModel
    private(set) var favoritesViewModel: CatBreedFavoritesViewModel
    private(set) var state: State

    private let favoritesManager: FavoritesManager

    // MARK: - Initialization

    init(
        initialState: State,
        favoritesManager: FavoritesManager
    ) {
        self.state = initialState
        self.favoritesManager = favoritesManager

        breedsViewModel = .init(
            initialState: initialState.breeds,
            repository: .live,
            favoritesManager: favoritesManager
        )
        favoritesViewModel = .init(
            initialState: initialState.favorites,
            repository: .live,
            favoritesManager: favoritesManager
        )
    }

    func send(_ action: Action) {
        switch action {
        case .onAppear:
            state.isLoading = true
            getFavorites()
        }
    }

    // MARK: - Private methods

    private func getFavorites() {
        Task {
            defer { state.isLoading = false }

            do {
               let _ = try await favoritesManager.fetchFavorites()
                print("Finished fetching favorites")
                state.isLoading = false
            } catch {
                print("Error fetching favorites: \(error)")
            }
        }
    }
}
