//
//  CatBreedsViewModel.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import Foundation

struct Pagination {
    var hasMoreItems: Bool = true
    var limit: Int = 10
    var nextPage: Int = 0
    var thresholdItemId: String?
}

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
                print("breeds updated - count: \(breeds.count)")
                if pagination.hasMoreItems {
                    updateThresholdItemId()
                }
            }
        }

        var isLoading: Bool = false
        var pagination: Pagination = .init()

        mutating func updateThresholdItemId() {
            let index = breeds.count - 3
            guard index > 0 else { return }

            pagination.thresholdItemId = breeds[index].id
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
            print("Card breed \(breed.name) appeared")
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

                state.pagination.hasMoreItems = response.breeds.count > 0
                if state.pagination.hasMoreItems {
                    state.pagination.nextPage += 1
                } else {
                    state.pagination.thresholdItemId = nil
                }
            } catch {
                print("Got error fetching breeds: \(error)")
            }
        }
    }

    private func handleItemAppeared(_ breed: Breed) {
        guard
            state.pagination.hasMoreItems,
            let thresholdItemId = state.pagination.thresholdItemId,
            breed.id == thresholdItemId
        else {
            return
        }

        fetchBreeds(page: state.pagination.nextPage)
    }
}

extension CatBreedsViewModel {
    subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        get { state[keyPath: keyPath] }
    }
}
