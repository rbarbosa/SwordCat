//
//  CatBreedDetailViewModelTests.swift
//  SwordCatTests
//
//  Created by Rui Barbosa on 25/11/2024.
//

//import ConcurrencyExtras
import Testing
@testable import SwordCat

struct CatBreedDetailViewModelTests {

    @Test("Initial state", .tags(.viewModels))
    func initialState() async throws {
        let sut = CatBreedDetailViewModel(
            initialState: .init(breed: .mock, isFavorite: true),
            favoritesManager: .init(repository: .success, user: .init()),
            parentActionHandler: { _ in }
        )

        #expect(sut.state.breed.name == "Abyssinian")
        #expect(sut.state.isFavorite)
        #expect(sut.state.isUpdating == false)
        #expect(sut.state.hasErrorUpdating == false)

        // Image cache should be empty
        await #expect(sut.state.image() == nil)
    }

    @Test("Mark as favorite", .tags(.viewModels))
    func markAsFavorite() async throws {
        var repositoryCalled = false
        var favoritesRepository: FavoritesRepository = .success

        favoritesRepository.markAsFavorite = { userId, imagedId in
            repositoryCalled = true

            #expect(userId == "sh-user-241122")
            #expect(imagedId == "0XYvRd7oD")

            return .init(id: 1)
        }

        let sut = CatBreedDetailViewModel(
            initialState: .init(breed: .mock, isFavorite: false),
            favoritesManager: .init(repository: favoritesRepository, user: .init()),
            parentActionHandler: { _ in }
        )

        #expect(sut.state.isFavorite == false)
        #expect(sut.state.isUpdating == false)
        #expect(sut.state.hasErrorUpdating == false)

        sut.send(.toggleFavorite)

        #expect(sut.state.isUpdating)

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))

        #expect(sut.state.isFavorite == true)
        #expect(sut.state.isUpdating == false)
        #expect(sut.state.hasErrorUpdating == false)
        #expect(repositoryCalled)
    }

    @Test("Mark as favorite with error should keep state", .tags(.viewModels))
    func markAsFavoriteWithError() async throws {
        let sut = CatBreedDetailViewModel(
            initialState: .init(breed: .mock, isFavorite: false),
            favoritesManager: .init(repository: .failure, user: .init()),
            parentActionHandler: { _ in }
        )

        #expect(sut.state.isFavorite == false)
        #expect(sut.state.isUpdating == false)
        #expect(sut.state.hasErrorUpdating == false)

        sut.send(.toggleFavorite)

        #expect(sut.state.isUpdating)

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))

        #expect(sut.state.isFavorite == false)
        #expect(sut.state.isUpdating == false)
        #expect(sut.state.hasErrorUpdating == true)
    }

    @Test("Mark as unfavorite", .tags(.viewModels))
    func markAsUnfavorite() async throws {
        var repositoryCalled = false
        var favoritesRepository: FavoritesRepository = .success

        favoritesRepository.markAsUnfavorite = { id in
            repositoryCalled = true

            #expect(id == 123)

            return .init(success: true)
        }

        let favoritesManager = FavoritesManager(repository: favoritesRepository, user: .init())

        let sut = CatBreedDetailViewModel(
            initialState: .init(breed: .mock, isFavorite: true),
            favoritesManager: favoritesManager,
            parentActionHandler: { _ in }
        )

        // fetch favorites
        _ = try await favoritesManager.fetchFavoriteImageIds()

        #expect(sut.state.isFavorite == true)
        #expect(sut.state.isUpdating == false)
        #expect(sut.state.hasErrorUpdating == false)

        sut.send(.toggleFavorite)

        #expect(sut.state.isUpdating)

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))

        #expect(sut.state.isFavorite == false)
        #expect(sut.state.isUpdating == false)
        #expect(sut.state.hasErrorUpdating == false)
        #expect(repositoryCalled)
    }

    @Test("Mark as unfavorite with error should keep state", .tags(.viewModels))
    func markAsUnfavoriteWithError() async throws {
        var favoritesRepository: FavoritesRepository = .success

        favoritesRepository.markAsUnfavorite = { _ in
            .init(success: false)
        }

        let favoritesManager = FavoritesManager(repository: favoritesRepository, user: .init())

        let sut = CatBreedDetailViewModel(
            initialState: .init(breed: .mock, isFavorite: true),
            favoritesManager: favoritesManager,
            parentActionHandler: { _ in }
        )

        // fetch favorites
        _ = try await favoritesManager.fetchFavoriteImageIds()

        #expect(sut.state.isFavorite == true)
        #expect(sut.state.isUpdating == false)
        #expect(sut.state.hasErrorUpdating == false)

        sut.send(.toggleFavorite)

        #expect(sut.state.isUpdating)

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))

        #expect(sut.state.isFavorite == true)
        #expect(sut.state.isUpdating == false)
        #expect(sut.state.hasErrorUpdating == true)
    }

    @Test("On dismiss should sent state to parent", .tags(.viewModels))
    func onDismiss() async throws {
        let sut = CatBreedDetailViewModel(
            initialState: .init(breed: .mock, isFavorite: false),
            favoritesManager: .init(repository: .success, user: .init()),
            parentActionHandler: { action in
                switch action {
                case .didDismiss(let breed, let newFavoriteState):
                    #expect(newFavoriteState != nil)
                    #expect(breed.name == "Abyssinian")
                    do {
                        let favorite = try #require(newFavoriteState as Bool?)
                        #expect(favorite == true)
                    } catch {
                        #expect(Bool(false))
                    }
                }
            }
        )

        sut.send(.toggleFavorite)

        // Give time for the async
        try await Task.sleep(for: .milliseconds(100))

        // Simulate dismiss
        sut.send(.onDisappear)
    }
}
