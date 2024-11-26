//
//  CatBreedFavoritesViewModelTests.swift
//  SwordCatTests
//
//  Created by Rui Barbosa on 26/11/2024.
//

import Testing
@testable import SwordCat

struct CatBreedFavoritesViewModelTests {

    @Test("Initial state", .tags(.viewModels))
    func initialState() async throws {
        let sut = CatBreedFavoritesViewModel(
            initialState: .init(),
            repository: .success,
            favoritesManager: .init(repository: .success, user: .init())
        )

        #expect(sut.state.destination == nil)
        #expect(sut.state.isLoading == false)
        #expect(sut.state.favorites.isEmpty)
    }

    @Test("On first appear should fetch favorites", .tags(.viewModels))
    func firstAppear() async throws {
        var repositoryCalled = false
        var favoritesRepository: FavoritesRepository = .success

        favoritesRepository.fetchFavorites = { userId in
            repositoryCalled = true
            #expect(userId == "sh-user-241122")

            return .init(favoriteImages: [.mock])
        }

        let sut = CatBreedFavoritesViewModel(
            initialState: .init(),
            repository: .success,
            favoritesManager: .init(repository: favoritesRepository, user: .init())
        )

        #expect(sut.state.isLoading == false)
        #expect(sut.state.favorites.isEmpty)

        sut.send(.onAppear)

        #expect(sut.state.isLoading == true)

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))

        #expect(sut.state.isLoading == false)

        let breed = try #require(sut.state.favorites.first)
        #expect(breed.name == "Abyssinian")

        #expect(repositoryCalled)
    }

    @Test("On subsequent appear should not fetch favorites", .tags(.viewModels))
    func secondAppear() async throws {
        var repositoryCalled = 0
        var favoritesRepository: FavoritesRepository = .success

        favoritesRepository.fetchFavorites = { userId in
            repositoryCalled += 1

            return .init(favoriteImages: [.mock])
        }

        let sut = CatBreedFavoritesViewModel(
            initialState: .init(),
            repository: .success,
            favoritesManager: .init(repository: favoritesRepository, user: .init())
        )

        #expect(sut.state.favorites.isEmpty)

        // First onAppear
        sut.send(.onAppear)

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))

        #expect(sut.state.favorites.isEmpty == false)
        #expect(repositoryCalled == 1)

        // Second onAppear
        sut.send(.onAppear)

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))

        #expect(sut.state.favorites.isEmpty == false)

        // Repository caller count should not increase
        #expect(repositoryCalled == 1)
    }

    @Test("Tapping on favorite breed should set destination", .tags(.viewModels))
    func tapOnFavoriteBreed() async throws {
        let sut = CatBreedFavoritesViewModel(
            initialState: .init(),
            repository: .success,
            favoritesManager: .init(repository: .success, user: .init())
        )
        
        #expect(sut.state.destination == nil)

        sut.send(.breedCardTapped(.mock))

        let destination = try #require(sut.state.destination)
        #expect(destination.is(\.detail))

        if case .detail(let viewModel) = destination {
            #expect(viewModel.state.breed.id == "abys")
            #expect(viewModel.state.breed.referenceImageId == "0XYvRd7oD")
            #expect(viewModel.state.isFavorite)
        } else {
            #expect(Bool(false), "Expected .detail destination.")
        }
    }

    @Test("On dismiss detail with changed favorite state", .tags(.viewModels))
    func onDismissDetailWithChangedState() async throws {
        let sut = CatBreedFavoritesViewModel(
            initialState: .init(),
            repository: .success,
            favoritesManager: .init(repository: .success, user: .init())
        )

        // we need a favorite
        sut.send(.onAppear)

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))

        #expect(!sut.state.favorites.isEmpty)

        #expect(sut.state.destination == nil)

        sut.send(.breedCardTapped(.mock))

        let destination = try #require(sut.state.destination)
        #expect(destination.is(\.detail))

        if case .detail(let viewModel) = destination {
            // Unfavorite breed
            viewModel.send(.toggleFavorite)

            // Give time for marking on API
            try await Task.sleep(for: .milliseconds(500))

            viewModel.send(.onDisappear)
        } else {
            #expect(Bool(false), "Expected .detail destination.")
        }

        #expect(sut.state.favorites.isEmpty)
    }

    @Test("On dismiss detail with unchanged favorite state", .tags(.viewModels))
    func onDismissDetailWithUnchangedState() async throws {
        let sut = CatBreedFavoritesViewModel(
            initialState: .init(),
            repository: .success,
            favoritesManager: .init(repository: .success, user: .init())
        )

        // we need a favorite
        sut.send(.onAppear)

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))

        #expect(!sut.state.favorites.isEmpty)

        #expect(sut.state.destination == nil)

        sut.send(.breedCardTapped(.mock))

        let destination = try #require(sut.state.destination)
        #expect(destination.is(\.detail))

        if case .detail(let viewModel) = destination {
            viewModel.send(.onDisappear)
        } else {
            #expect(Bool(false), "Expected .detail destination.")
        }

        #expect(!sut.state.favorites.isEmpty)
    }

    @Test("Add favorite action", .tags(.viewModels))
    func addFavorite() async throws {
        let sut = CatBreedFavoritesViewModel(
            initialState: .init(),
            repository: .success,
            favoritesManager: .init(repository: .success, user: .init())
        )

        #expect(sut.state.favorites.isEmpty)

        sut.send(.addFavorite(.mock))

        #expect(!sut.state.favorites.isEmpty)
    }

    @Test("Remove favorite action", .tags(.viewModels))
    func removeFavorite() async throws {
        let sut = CatBreedFavoritesViewModel(
            initialState: .init(),
            repository: .success,
            favoritesManager: .init(repository: .success, user: .init())
        )

        #expect(sut.state.favorites.isEmpty)

        sut.send(.addFavorite(.mock))

        #expect(!sut.state.favorites.isEmpty)

        sut.send(.removeFavorite(.mock))

        #expect(sut.state.favorites.isEmpty)
    }

    @Test("Breed card appear action", .tags(.viewModels))
    func breedCardAppear() async throws {
        let imageCache = ImageCache.shared

        let sut = CatBreedFavoritesViewModel(
            initialState: .init(),
            repository: .success,
            favoritesManager: .init(repository: .success, user: .init())
        )

        let imageMock = createMockImage()
        await imageCache.setImage(imageMock, for: Breed.mock.url)

        sut.send(.addFavorite(.mock))

        sut.send(.breedCardAppeared(.mock))

        // Give time for loading the image
        try await Task.sleep(for: .milliseconds(200))

        let imageState = sut.state.imageState(for: .mock)

        if case .loaded(let image) = imageState {
            #expect(image == imageMock)
        } else {
            #expect(Bool(false), "Expected loaded state with image")
        }
    }
}
