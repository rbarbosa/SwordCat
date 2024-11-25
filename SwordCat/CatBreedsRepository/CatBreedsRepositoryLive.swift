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
            fetchBreeds: { page in
                let data = try await networking.fetch(query: .breeds(page: page))
                return try makeBreedsRepositoryResponse(from: data)
            },
            searchBreeds: { query in
                let data = try await networking.fetch(query: .searchBreed(query))
                return try makeBreedsRepositoryResponse(from: data)
            }
        )
    }
}
