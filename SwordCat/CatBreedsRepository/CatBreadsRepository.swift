//
//  CatBreedsRepository.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import Foundation

struct CatBreedsRepository {
    var fetchImages: () async throws -> ImagesRepositoryResponse

    var fetchBreeds: (_ page: Int) async throws -> BreedsRepositoryResponse

    var searchBreeds: (_ query: String) async throws -> BreedsRepositoryResponse

    var markAsFavorite: (_ userId: String, _ imageId: String) async throws -> MarkAsFavoriteRepositoryResponse

    var markAsUnfavorite: (_ id: Int) async -> MarkAsUnfavoriteRepositoryResponse
}
