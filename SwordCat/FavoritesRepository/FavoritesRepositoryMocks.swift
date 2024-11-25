//
//  FavoritesRepositoryMocks.swift
//  SwordCat
//
//  Created by Rui Barbosa on 25/11/2024.
//

// MARK: - Mocks

#if DEBUG
extension FavoritesRepository {
    static var success: Self {
        .init(
            fetchBreedImage: { _ in
                .init(breed: .mock)
            },
            fetchFavorites: { _ in
                .init(favoriteImages: [.mock])
            },
            markAsFavorite: { _, _  in
                .init(id: 1)
            },
            markAsUnfavorite: { _ in
                .init(success: true)
            }
        )
    }

    static var failure: Self {
        .init(
            fetchBreedImage: { _ in
                throw NetworkingError.invalidResponse
            },
            fetchFavorites: { _ in
                throw NetworkingError.invalidResponse
            },
            markAsFavorite: { _, _  in
                throw NetworkingError.invalidResponse
            },
            markAsUnfavorite: { _ in
                .init(success: false)
            }
        )
    }
}
#endif
