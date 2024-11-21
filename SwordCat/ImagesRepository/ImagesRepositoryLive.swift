//
//  ImagesRepositoryLive.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import Foundation

// MARK: - Live implementation

extension CatBreadsRepository {
    static var live: CatBreadsRepository {
        let networking = Networking()

        return .init(
            fetchImages: {
                let data = try await networking.fetchURL(forQuery: .images(page: 0))
                return try makeImagesRepositoryResponse(from: data)
            }
        )
    }
}
