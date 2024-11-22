//
//  MarkAsFavoriteRepositoryResponse.swift
//  SwordCat
//
//  Created by Rui Barbosa on 22/11/2024.
//

import Foundation

struct MarkAsFavoriteRepositoryResponse: Decodable {
    let id: Int
}

func makeMarkAsFavoriteRepositoryResponse(from data: Data) throws -> MarkAsFavoriteRepositoryResponse {
    do {
        return try JSONDecoder().decode(MarkAsFavoriteRepositoryResponse.self, from: data)
    } catch {
        throw NetworkingError.decodingFailed(error)
    }
}
