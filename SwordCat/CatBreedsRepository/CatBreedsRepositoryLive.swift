//
//  CatBreedsRepository.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import Foundation

// MARK: - Live implementation

extension CatBreedsRepository {
    static var live: CatBreedsRepository {
        let networking = Networking()

        return .init(
            fetchImages: {
                let data = try await networking.fetch(query: .images(page: 0))
                return try makeImagesRepositoryResponse(from: data)
            },
            fetchBreeds: { page in
                let data = try await networking.fetch(query: .breeds(page: page))
                return try makeBreedsRepositoryResponse(from: data)
            },
            searchBreeds: { query in
                let data = try await networking.fetch(query: .searchBreed(query))
                return try makeBreedsRepositoryResponse(from: data)
            },
            markAsFavorite: { userId, imageId in
                let input = MarkFavoriteInput(userId: userId, imageId: imageId)
                let data = try await networking.perform(mutationQuery: .markFavorite(input))
                return try makeMarkAsFavoriteRepositoryResponse(from: data)
            },
            markAsUnfavorite: { favoriteId in
                do {
                   _ = try await networking.perform(mutationQuery: .unfavorite(favoriteId: favoriteId))
                    return .init(success: true)
                } catch {
                    return .init(success: false)
                }
            },
            fetchFavorites: { userId in
                let data = try await networking.fetch(query: .favorites)
                let response = try makeFavoritesRepositoryResponse(from: data)
                let favorites = response.favorites.filter { $0.subId == userId }
                return .init(favorites: favorites)
            }
        )
    }
}
