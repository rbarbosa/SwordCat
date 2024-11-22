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
            isSearching ? filteredBreeds : fetchedBreeds
        }

        var isLoading: Bool = false
        var isSearching: Bool = false
        var favoriteBreedIds: [String: Bool] = [:]
        var pagination: Pagination = .init()
        let user: User = .init()

        fileprivate var fetchedBreeds: [Breed] = []
        fileprivate var filteredBreeds: [Breed] = []

        mutating func updateThresholdItemId() {
            let index = breeds.count - 3
            guard index > 0 else { return }

            pagination.thresholdItemId = breeds[index].id
        }

        func isFavorite(_ breed: Breed) -> Bool {
            favoriteBreedIds[breed.id] ?? false
        }
    }

    // MARK: - Action

    enum Action {
        case favoriteButtonTapped(Breed)
        case search(String)
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
        case .favoriteButtonTapped(let breed):
            print("Favorite button tapped for \(breed.name)")
            handleFavoriteTapped(breed)

        case .search(let query):
            state.isSearching = !query.isEmpty
            search(query.lowercased())


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
                state.fetchedBreeds.append(contentsOf: response.breeds)

                state.pagination.hasMoreItems = response.breeds.count > 0
                if state.pagination.hasMoreItems {
                    state.pagination.nextPage += 1
                    state.updateThresholdItemId()
                } else {
                    state.pagination.thresholdItemId = nil
                }
            } catch {
                state.isLoading = false
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

    private func handleFavoriteTapped(_ breed: Breed) {
        Task {
            do {
                _ = try await repository.markAsFavorite(state.user.id, breed.referenceImageId)
                markBreedAsFavorite(breed)
            } catch {
                print("Error marking breed as favorite: \(error)")
            }
        }
    }

    private func markBreedAsFavorite(_ breed: Breed) {
        guard let value = state.favoriteBreedIds[breed.id] else {
            state.favoriteBreedIds[breed.id] = true
            return
        }

        state.favoriteBreedIds[breed.id] = !value
    }

    private func search(_ query: String) {
        // Search first within the items already fetched
        guard !state.fetchedBreeds.isEmpty else {
            searchBreed(query)
            return
        }

        let predicate = #Predicate<Breed> {
            $0.name.localizedStandardContains(query)
        }

        let filteredBreeds = try? state.fetchedBreeds.filter(predicate)

        if let filteredBreeds, !filteredBreeds.isEmpty {
            state.filteredBreeds = filteredBreeds
            return
        }

        // Not found breed within fetched breeds, search with API
        searchBreed(query)
    }

    private func searchBreed(_ withQuery: String) {
        state.isLoading = true
        Task {
            do {
                let response = try await repository.searchBreeds(withQuery)
                state.filteredBreeds = response.breeds
                state.isLoading = false
            } catch {
                state.isLoading = false
                print("Error searching breeds: \(error.localizedDescription)")
            }
        }
    }
}

extension CatBreedsViewModel {
    subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        get { state[keyPath: keyPath] }
    }
}
