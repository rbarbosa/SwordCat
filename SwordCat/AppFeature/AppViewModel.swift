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
        case breedsViewModel(CatBreedsViewModel.Action.Delegate)
        case onAppear
    }

    // MARK: - Properties

    private(set) var breedsViewModel: CatBreedsViewModel
    private(set) var favoritesViewModel: CatBreedFavoritesViewModel
    private(set) var state: State

    private let favoritesManager: FavoritesManager
    private let catBreedsRepository: CatBreedsRepository
    private let favoritesRepository: FavoritesRepository
    private let user: User

    // MARK: - Initialization

    init(
        initialState: State,
        catBreedsRepository: CatBreedsRepository,
        favoritesRepository: FavoritesRepository,
        user: User = .init()
    ) {
        self.state = initialState
        self.catBreedsRepository = catBreedsRepository
        self.favoritesRepository = favoritesRepository
        self.user = user
        favoritesManager = .init(repository: favoritesRepository, user: user)

        breedsViewModel = .init(
            initialState: initialState.breeds,
            repository: catBreedsRepository,
            favoritesManager: favoritesManager,
            parentActionHandler: { _ in }
        )

        favoritesViewModel = .init(
            initialState: initialState.favorites,
            repository: catBreedsRepository,
            favoritesManager: favoritesManager
        )

        setUpChildViewModels()
    }

    func send(_ action: Action) {
        switch action {
        case .breedsViewModel(let delegateAction):
            handleBreedsViewModelAction(delegateAction)

        case .onAppear:
            state.isLoading = true
            getFavorites()
        }
    }

    // MARK: - Private methods

    private func setUpChildViewModels() {
        breedsViewModel = .init(
            initialState: state.breeds,
            repository: catBreedsRepository,
            favoritesManager: favoritesManager,
            parentActionHandler: { [weak self] in
                self?.send(.breedsViewModel($0))
            }
        )
    }

    private func getFavorites() {
        Task {
            defer { state.isLoading = false }

            do {
                let _ = try await favoritesManager.fetchFavoriteImageIds()
            } catch {
                // TODO: - Handle this state
                // We could either retry (by adding a retry button) or we could inform the breeds view model
                // that need to refresh favorites. While we don't successfully fetch the favorites
                // we should disable favoriting breeds to prevent inconsistencies
                print("❌ Error fetching favorites: \(error)")
            }
        }
    }

    private func handleBreedsViewModelAction(_ action: CatBreedsViewModel.Action.Delegate) {
        switch action {
        case .didFavorite(let breed):
            favoritesViewModel.send(.addFavorite(breed))

        case .didUnfavorite(let breed):
            favoritesViewModel.send(.removeFavorite(breed))
        }
    }
}
