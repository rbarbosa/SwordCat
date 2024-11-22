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
}