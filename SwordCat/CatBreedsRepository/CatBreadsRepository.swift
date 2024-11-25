//
//  CatBreedsRepository.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import Foundation

struct CatBreedsRepository {
    var fetchBreeds: (_ page: Int) async throws -> BreedsRepositoryResponse

    var searchBreeds: (_ query: String) async throws -> BreedsRepositoryResponse
}
