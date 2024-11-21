//
//  CatBreedsViewModel.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import Foundation

@Observable
@dynamicMemberLookup
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
    private let repository: CatBreadsRepository

    // MARK: - Initialization

    init(
        initialState: State,
        repository: CatBreadsRepository
    ) {
        self.state = initialState
        self.repository = repository
    }

    func send(_ action: Action) {
        switch action {
        case .onAppear:
            // Start searching
            fetchBreeds()
        }
    }

    private func fetchBreeds() {
        Task {
            let response = try await imagesRepository.fetchImages()
            state.breeds = response.breeds
        }
    }
}

extension CatBreedsViewModel {
    subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        get { state[keyPath: keyPath] }
    }
}
