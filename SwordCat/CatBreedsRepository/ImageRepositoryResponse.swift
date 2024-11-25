//
//  ImageRepositoryResponse.swift
//  SwordCat
//
//  Created by Rui Barbosa on 23/11/2024.
//

import Foundation

struct ImageRepositoryResponse {
    let breed: Breed
}

private struct ImageResponse: Decodable {
    let id: String
    let url: String
    let breeds: [BreedResponse]
}

private struct BreedResponse: Decodable {
    let description: String
    let id: String
    let lifeSpan: String
    let name: String
    let origin: String
    let temperament: String

    enum CodingKeys: String, CodingKey {
        case description
        case id
        case lifeSpan = "life_span"
        case name
        case origin
        case temperament
    }
}

func makeImageRepositoryResponse(from data: Data) throws -> ImageRepositoryResponse {
    do {
        let response = try JSONDecoder().decode(ImageResponse.self, from: data)
        guard
            let breedResponse = response.breeds.first,
            let url = URL(string: response.url)
        else {
            let error: NSError = .init(domain: "Not found breed", code: 0)
            throw NetworkingError.decodingFailed(error)
        }

        let breed = Breed(
            description: breedResponse.description,
            id: breedResponse.id,
            lifeSpan: breedResponse.lifeSpan,
            name: breedResponse.name,
            origin: breedResponse.origin,
            referenceImageId: response.id,
            temperament: breedResponse.temperament,
            url: url
        )

        return .init(breed: breed)
    } catch {
        throw NetworkingError.decodingFailed(error)
    }
}
