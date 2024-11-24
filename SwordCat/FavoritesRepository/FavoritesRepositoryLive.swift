//
//  FavoritesRepositoryLive.swift
//  SwordCat
//
//  Created by Rui Barbosa on 24/11/2024.
//


extension FavoritesRepository {
    static var live: Self {
        let networking = Networking()

        return .init(
            fetchBreedImage: { imageId in
                let data = try await networking.fetch(query: .image(imageId: imageId))
                let response = try makeImageRepositoryResponse(from: data)
                return .init(breed: response.breed)
            },
            fetchFavorites: { userId in
                let date = try await networking.fetch(query: .favorites)
                return try makeFetchFavoritesRepositoryResponse(from: date, userId: userId)
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
            }
        )
    }
}
