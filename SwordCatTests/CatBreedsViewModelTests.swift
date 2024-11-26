//
//  CatBreedsViewModelTests.swift
//  SwordCatTests
//
//  Created by Rui Barbosa on 26/11/2024.
//

import Testing
@testable import SwordCat

struct CatBreedsViewModelTests {

    @Test("Initial state", .tags(.viewModels))
    func initialState() async throws {
        let sut = CatBreedsViewModel(
            initialState: .init(),
            repository: .success,
            favoritesManager: .init(repository: .success, user: .init()),
            parentActionHandler: { _ in }
        )

        #expect(sut.state.destination == nil)
        #expect(sut.state.hasFetchingError == false)
        #expect(sut.state.isLoading == false)
        #expect(sut.state.isSearching == false)
        #expect(sut.state.favoriteBreedIds.isEmpty)
        #expect(sut.state.pagination.nextPage == 0)
        #expect(sut.state.user.id == "sh-user-241122")
    }

    @Test("On first appear should get favorites and breeds", .tags(.viewModels))
    func firstAppear() async throws {
        let favoritesRepository: FavoritesRepository = .success
        var breedsRepository: CatBreedsRepository = .success
        var breedsRepositoryCalled = false

        breedsRepository.fetchBreeds = { page in
            breedsRepositoryCalled = true
            #expect(page == 0)

            return .init(breeds: [.mock])
        }

        let favoritesManager: FavoritesManager = .init(repository: favoritesRepository, user: .init())

        let sut = CatBreedsViewModel(
            initialState: .init(),
            repository: breedsRepository,
            favoritesManager: favoritesManager,
            parentActionHandler: { _ in }
        )

        // Previous fetch the favorites
        _ = try await favoritesManager.fetchFavoriteImageIds()

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))

        sut.send(.onAppear)

        #expect(sut.state.isLoading)

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))

        #expect(sut.state.isLoading == false)
        #expect(breedsRepositoryCalled)

        #expect(sut.state.favoriteBreedIds.isEmpty == false)
        let breedId = try #require(sut.state.favoriteBreedIds.first)
        #expect(breedId == "0XYvRd7oD")

        #expect(sut.state.isFavorite(.mock))
    }

    @Test("On subsequent appear should not fetch breeds", .tags(.viewModels))
    func subsequentAppear() async throws {
        var breedsRepository: CatBreedsRepository = .success
        var repositoryCalled = 0

        breedsRepository.fetchBreeds = { page in
            repositoryCalled += 1
            return .init(breeds: [.mock])
        }

        let sut = CatBreedsViewModel(
            initialState: .init(),
            repository: breedsRepository,
            favoritesManager: .init(repository: .success, user: .init()),
            parentActionHandler: { _ in }
        )

        // First appear
        sut.send(.onAppear)

        #expect(sut.state.isLoading)

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))

        #expect(repositoryCalled == 1)

        // Second onAppear
        sut.send(.onAppear)

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))

        // Repository caller count should not increase
        #expect(repositoryCalled == 1)
    }

    @Test("Breed tapped should set details destination", .tags(.viewModels))
    func breedTapped() async throws {
        let favoritesManager: FavoritesManager = .init(repository: .success, user: .init())

        let sut = CatBreedsViewModel(
            initialState: .init(),
            repository: .success,
            favoritesManager: favoritesManager,
            parentActionHandler: { _ in }
        )

        // Previous fetch the favorites
        _ = try await favoritesManager.fetchFavoriteImageIds()

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))

        sut.send(.onAppear)

        #expect(sut.state.isLoading)

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))
    }

    @Test("Favorite button tapped for unfavorite breed", .tags(.viewModels))
    func breedFavoriteButtonTapped() async throws {
        var repositoryCalled = false
        var favoritesRepository: FavoritesRepository = .success

        favoritesRepository.fetchFavorites = { _ in
            .init(favoriteImages: [])
        }

        favoritesRepository.markAsFavorite = { userId, imagedId in
            repositoryCalled = true

            #expect(userId == "sh-user-241122")
            #expect(imagedId == "0XYvRd7oD")

            return .init(id: 1)
        }

        let favoritesManager: FavoritesManager = .init(repository: favoritesRepository, user: .init())

        let sut = CatBreedsViewModel(
            initialState: .init(),
            repository: .success,
            favoritesManager: favoritesManager,
            parentActionHandler: { _ in }
        )

        // Previous fetch the favorites
        _ = try await favoritesManager.fetchFavoriteImageIds()

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))

        sut.send(.onAppear)

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))
        #expect(sut.state.isFavorite(.mock) == false)

        // Tap on favorite
        sut.send(.favoriteButtonTapped(.mock))

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))

        #expect(repositoryCalled)
        #expect(sut.state.isFavorite(.mock))
    }
}
