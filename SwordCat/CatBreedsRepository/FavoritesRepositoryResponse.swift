//
//  FavoritesRepositoryResponse.swift
//  SwordCat
//
//  Created by Rui Barbosa on 23/11/2024.
//

import Foundation

struct FavoritesRepositoryResponse {
    let favorites: [FavoriteBreed]
}

private struct FavoriteResponse: Decodable {
    let id: Int
    let imageId: String
    let subId: String

    enum CodingKeys: String, CodingKey {
        case id
        case imageId = "image_id"
        case subId = "sub_id"
    }
}

func makeFavoritesRepositoryResponse(from data: Data) throws -> FavoritesRepositoryResponse {
    do {
        let response = try JSONDecoder().decode([FavoriteResponse].self, from: data)
        let favorites: [FavoriteBreed] = response.map {
            .init(id: $0.id, imageId: $0.imageId, subId: $0.subId)
        }

        return .init(favorites: favorites)
    } catch {
        throw NetworkingError.decodingFailed(error)
    }
}
