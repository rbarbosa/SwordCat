//
//  CatBreedsViewModel.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import Foundation

@Observable
final class CatBreedsViewModel {

    // MARK: - Destination

    enum Destination {
    }

    // MARK: - State

    struct State {
        var breeds: [Breed]
    }

    // MARK: - Action

    enum Action {
        case onAppear
    }

    // MARK: - Properties

    private(set) var state: State

    // MARK: - Initialization

    init(initialState: State) {
        self.state = initialState
    }

    func send(_ action: Action) {
        switch action {
        case .onAppear:
            // Start searching
            fetchBreeds()
        }
    }

    private func fetchBreeds() {
        // Implement fetch
        state.breeds = [.mock]
    }
}
