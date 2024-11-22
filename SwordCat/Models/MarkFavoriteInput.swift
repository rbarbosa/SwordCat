//
//  MarkFavoriteInput.swift
//  SwordCat
//
//  Created by Rui Barbosa on 22/11/2024.
//

import Foundation

struct MarkFavoriteInput: Encodable {
    let userId: String
    let imageId: String

    enum CodingKeys: String, CodingKey {
        case userId = "sub_id"
        case imageId = "image_id"
    }
}
