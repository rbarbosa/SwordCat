//
//  FavoritesRepository.swift
//  SwordCat
//
//  Created by Rui Barbosa on 24/11/2024.
//

import Foundation

// While it's not replaced the later
typealias BreedImageRepositoryResponse = ImageRepositoryResponse

struct FavoritesRepository {
    var fetchBreedImage: (_ imageId: String) async throws -> BreedImageRepositoryResponse

    var fetchFavorites: (_ userId: String) async throws -> FetchFavoritesRepositoryResponse

    var markAsFavorite: (_ userId: String, _ imageId: String) async throws -> MarkAsFavoriteRepositoryResponse

    var markAsUnfavorite: (_ id: Int) async -> MarkAsUnfavoriteRepositoryResponse
}


