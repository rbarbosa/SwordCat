//
//  CatBreedsRepositoryMocks.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import Foundation

// MARK: - Mocks

#if DEBUG
extension CatBreedsRepository {
    static var success: Self {
        .init(
            fetchBreeds: { _ in
                .init(breeds: [.mock])
            },
            searchBreeds: { _ in
                .init(breeds: [.mock])
            }
        )
    }

    static var failure: Self {
        .init(
            fetchBreeds: { _ in
                throw NetworkingError.invalidResponse
            },
            searchBreeds: { _ in
                throw NetworkingError.invalidResponse
            }
        )
    }
}
#endif
