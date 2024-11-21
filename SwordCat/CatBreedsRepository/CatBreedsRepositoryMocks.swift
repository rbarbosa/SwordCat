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
            }
        )
    }
}
#endif
