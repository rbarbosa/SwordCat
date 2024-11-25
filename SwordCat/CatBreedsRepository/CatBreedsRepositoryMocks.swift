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
            fetchImages: {
                .init(breeds: [.mock])
            },
            fetchBreeds: { _ in
                .init(breeds: [.mock])
            },
            searchBreeds: { _ in
                .init(breeds: [.mock])
            },
            markAsFavorite: { _, _ in
                .init(id: 123)
            },
            markAsUnfavorite: { _ in
                .init(success: true)
            },
            fetchFavorites: { _ in
                .init(favorites: [.init(id: 1, imageId: "image_id", subId: "sub_id")])
            },
            fetchImage: { _ in
                .init(breed: .mock)
            }
        )
    }

    static var failure: Self {
        .init(
            fetchImages: {
                throw NetworkingError.invalidResponse
            },
            fetchBreeds: { _ in
                throw NetworkingError.invalidResponse
            },
            searchBreeds: { _ in
                throw NetworkingError.invalidResponse
            },
            markAsFavorite: { _, _ in
                throw NetworkingError.invalidResponse
            },
            markAsUnfavorite: { _ in
                .init(success: false)
            },
            fetchFavorites: { _ in
                throw NetworkingError.invalidResponse
            },
            fetchImage: { _ in
                throw NetworkingError.invalidResponse
            }
        )
    }
}
#endif
