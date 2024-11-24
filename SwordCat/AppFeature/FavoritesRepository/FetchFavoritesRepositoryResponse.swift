//
//  FetchFavoritesRepositoryResponse.swift
//  SwordCat
//
//  Created by Rui Barbosa on 24/11/2024.
//

import Foundation

struct FetchFavoritesRepositoryResponse {
    let favoriteImages: [FavoriteImage]
}

private struct FavoriteImageResponse: Decodable {
    let id: Int
    let imageId: String
    let subId: String

    enum CodingKeys: String, CodingKey {
        case id
        case imageId = "image_id"
        case subId = "sub_id"
    }
}

func makeFetchFavoritesRepositoryResponse(from data: Data, userId: String) throws -> FetchFavoritesRepositoryResponse {
    do {
        let response = try JSONDecoder().decode([FavoriteImageResponse].self, from: data)
        let userFavorites = response.filter { $0.subId == userId }
        let favorites: [FavoriteImage] = userFavorites.map {
            .init(id: $0.id, imageId: $0.imageId)
        }

        return .init(favoriteImages: favorites)
    } catch {
        throw NetworkingError.decodingFailed(error)
    }
}
