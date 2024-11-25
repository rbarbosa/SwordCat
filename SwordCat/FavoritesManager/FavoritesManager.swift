//
//  FavoritesManager.swift
//  SwordCat
//
//  Created by Rui Barbosa on 24/11/2024.
//

import Foundation
import IdentifiedCollections

actor FavoritesManager {
    // This shouldn't be necessary
    var favoritesImage: IdentifiedArrayOf<FavoriteImage> = []
    var favoriteBreeds: IdentifiedArrayOf<Breed> = []
    var favoriteBreedIds: [String: Int] = [:]
    
    /// Handy dictionary where the key is the `imageId` and the value is favorite `id`
    var favoriteImageIds: [String: Int] = [:]

    private var didFetchFavoriteIds: Bool = false

    let repository: FavoritesRepository
    let user: User

    init(
        repository: FavoritesRepository,
        user: User
    ) {
        self.repository = repository
        self.user = user
    }

    func fetchFavoriteImageIds() async throws -> IdentifiedArrayOf<FavoriteImage> {
        let response = try await repository.fetchFavorites(user.id)
        var newFavorites: IdentifiedArrayOf<FavoriteImage> = []

        if favoriteBreeds.isEmpty {
            newFavorites = .init(uniqueElements: response.favoriteImages)
            favoritesImage = newFavorites
        } else {
            let filteredFavorites = response.favoriteImages.filter { newFavoriteImage in
                !favoritesImage.contains(where: { $0.imageId == newFavoriteImage.imageId })
            }
            newFavorites = .init(uniqueElements: filteredFavorites)
            favoritesImage.append(contentsOf: filteredFavorites)
        }

        for favorite in newFavorites {
            favoriteImageIds[favorite.imageId] = favorite.id
        }

        didFetchFavoriteIds = true

        return favoritesImage
    }

    func fetchFavoriteBreeds() async throws -> IdentifiedArrayOf<Breed> {
        if !didFetchFavoriteIds {
            _ = try await fetchFavoriteImageIds()
        }

        for imageId in favoriteImageIds.keys {
            let response = try await repository.fetchBreedImage(imageId)
            favoriteBreeds.append(response.breed)
        }

        return favoriteBreeds
    }

    func addFavorite(_ breed: Breed) async -> Bool {
        if let _ = favoriteImageIds[breed.referenceImageId] {
            // It's already marked as favorite
            return true
        }

        do {
            let response = try await repository.markAsFavorite(user.id, breed.referenceImageId)
            favoriteBreedIds[breed.id] = response.id
            favoriteBreeds[id: breed.id] = breed
            let favImage = FavoriteImage(id: response.id, imageId: breed.referenceImageId)
            favoritesImage[id: favImage.id] = favImage
            favoriteImageIds[breed.referenceImageId] = response.id

            return true
        } catch {
            return false
        }
    }

    func removeFavorite(_ breed: Breed) async -> Bool {
        guard let favoriteId = favoriteImageIds[breed.referenceImageId] else { return false }

        let response = await repository.markAsUnfavorite(favoriteId)
        if response.success {
            favoriteBreedIds[breed.id] = nil
            favoriteBreeds.remove(id: breed.id)
            favoritesImage.remove(id: favoriteId)
            favoriteImageIds[breed.referenceImageId] = nil

            return true
        }

        return false
    }
}
