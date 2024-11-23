//
//  CatBreedDetailViewModel.swift
//  SwordCat
//
//  Created by Rui Barbosa on 23/11/2024.
//

import Foundation

@Observable
final class CatBreedDetailViewModel {

    // MARK: - Destination

    enum Destination {
    }

    // MARK: - State

    struct State {
        let breed: Breed
        var isFavorite: Bool
    }

    // MARK: - Action

    enum Action {
        case toggleFavorite
    }

    private(set) var state: State

    // MARK: - Initialization

    init(initialState: State) {
        self.state = initialState
    }

    func send(_ action: Action) {
        switch action {
        case .toggleFavorite:
            state.isFavorite.toggle()
        }
    }
}
