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
    
    /// Handy dictionary where the key is the `imageId` and the value is favorite `id`
    var favoriteImageIds: [String: Int] = [:]

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
        return favoritesImage
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
            print("Failed to added favorite - \(breed.name) with id: \(breed.referenceImageId)")
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
