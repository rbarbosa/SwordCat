//
//  FavoriteImage.swift
//  SwordCat
//
//  Created by Rui Barbosa on 25/11/2024.
//

struct FavoriteImage: Identifiable {
    var id: Int
    var imageId: String
}

// MARK: - Mocks

#if DEBUG
extension FavoriteImage {
    static var mock: Self {
        .init(
            id: 1,
            imageId: "imageId"
        )
    }
}
#endif
