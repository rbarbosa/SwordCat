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
    }

    // MARK: - Action

    enum Action {
    }

    // MARK: - Properties

    private(set) var state: State

    // MARK: - Initialization

    init(initialState: State) {
        self.state = initialState
    }

    func send(_ action: Action) {
        switch action {
        }
    }
}
