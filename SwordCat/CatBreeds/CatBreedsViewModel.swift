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
        var breeds: [Breed] {
            didSet {
                if hasMoreItems {
                    updateThresholdItemId()
                }
            }
        }
        var isLoading: Bool = false
        var nextPage: Int = 0
        var hasMoreItems: Bool = true
        var thresholdItemId: String?

        mutating func updateThresholdItemId() {
            let index = breeds.count - 3
            guard index > 0 else { return }

            thresholdItemId = breeds[index].id
        }
    }

    // MARK: - Action

    enum Action {
        case onAppear
        case onCardBreedAppear(Breed)
    }

    private enum Constants {
        static let fetchLimit: Int = 10
    }

    // MARK: - Properties

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
            fetchBreeds(page: 0)

        case .onCardBreedAppear(let breed):
            handleItemAppeared(breed)
        }
    }

    private func fetchBreeds(page: Int) {
        state.isLoading = true
        Task {
            do {
                let response = try await repository.fetchBreeds(page)

                state.isLoading = false
                state.breeds.append(contentsOf: response.breeds)
                state.hasMoreItems = response.breeds.count > 0
                if state.hasMoreItems {
                    state.nextPage += 1
                } else {
                    state.thresholdItemId = nil
                }
            } catch {
                print("Got error fetching breeds: \(error)")
            }
        }
    }

    private func handleItemAppeared(_ breed: Breed) {
        guard
            state.hasMoreItems,
            let thresholdItemId = state.thresholdItemId,
            breed.id == thresholdItemId
        else {
            return
        }

        fetchBreeds(page: state.nextPage)
    }
}

extension CatBreedsViewModel {
    subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        get { state[keyPath: keyPath] }
    }
}
