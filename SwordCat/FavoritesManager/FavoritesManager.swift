//
//  FavoritesManager.swift
//  SwordCat
//
//  Created by Rui Barbosa on 24/11/2024.
//

import Foundation
import IdentifiedCollections

struct FavoriteImage: Identifiable {
    var id: Int
    var imageId: String
}

// FavoritesRepository
actor FavoritesManager {
    // This shouldn't be necessary
    var favoritesImage: IdentifiedArrayOf<FavoriteImage> = []
    var favoriteBreeds: IdentifiedArrayOf<Breed> = []
    var favoriteBreedIds: [String: Int] = [:]

    let repository: FavoritesRepository
    let user: User

    init(
        repository: FavoritesRepository,
        user: User
    ) {
        self.repository = repository
        self.user = user
    }

    func fetchFavorites() async throws -> IdentifiedArrayOf<Breed> {
        let response = try await repository.fetchFavorites(user.id)
        var newFavorites: IdentifiedArrayOf<FavoriteImage> = []

        if favoriteBreeds.isEmpty {
            newFavorites = .init(uniqueElements: response.favoriteImages)
            favoritesImage = newFavorites
        } else {
            let filteredFavorites = response.favoriteImages.filter { newFavoriteImage in
                !favoritesImage.contains(where: { $0.imageId == newFavoriteImage.imageId })
            }
            favoritesImage.append(contentsOf: filteredFavorites)
        }

        // Get images and breeds associated
        for favorite in newFavorites {
            let response = try await repository.fetchBreedImage(favorite.imageId)
            favoriteBreeds.append(response.breed)
            favoriteBreedIds[response.breed.id] = favorite.id
        }

        return favoriteBreeds
    }

    func addFavorite(_ breed: Breed) async -> Bool {
        do {
            let response = try await repository.markAsFavorite(user.id, breed.referenceImageId)
            favoriteBreedIds[breed.id] = response.id
            favoriteBreeds[id: breed.id] = breed
            let favImage = FavoriteImage(id: response.id, imageId: breed.referenceImageId)
            favoritesImage[id: favImage.id] = favImage

            return true
        } catch {
            return false
        }
    }

    func removeFavorite(_ breed: Breed) async -> Bool {
        guard let favoriteId = favoriteBreedIds[breed.id] else { return false }

        let response = await repository.markAsUnfavorite(favoriteId)
        if response.success {
            favoriteBreedIds[breed.id] = nil
            favoriteBreeds.remove(id: breed.id)
            favoritesImage.remove(id: favoriteId)

            return true
        }
        
        return false
    }
}
