//
//  BreedsRepositoryResponse.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import Foundation

struct BreedsRepositoryResponse {
    let breeds: [Breed]
}

// MARK: - Private structs to help decoding

private struct BreedResponse: Decodable {
    let description: String
    let id: String
    let lifeSpan: String
    let name: String
    let origin: String
    let temperament: String
    let referenceImageId: String?
    let image: ImageResponse?

    enum CodingKeys: String, CodingKey {
        case description
        case id
        case lifeSpan = "life_span"
        case name
        case origin
        case temperament
        case referenceImageId = "reference_image_id"
        case image
    }
}

private struct ImageResponse: Decodable {
    let url: String
}

func makeBreedsRepositoryResponse(from data: Data) throws -> BreedsRepositoryResponse {
    do {
        let breedsResponse = try JSONDecoder().decode([BreedResponse].self, from: data)
        let breeds: [Breed] = breedsResponse.compactMap { breedResponse in
            guard
                let image = breedResponse.image,
                let referenceImageId = breedResponse.referenceImageId,
                let imageUrl = URL(string: image.url) else { return nil }

            return .init(
                description: breedResponse.description,
                id: breedResponse.id,
                lifeSpan: breedResponse.lifeSpan,
                name: breedResponse.name,
                origin: breedResponse.origin,
                referenceImageId: referenceImageId,
                temperament: breedResponse.temperament,
                url: imageUrl
            )
        }
        return .init(breeds: breeds)
    } catch {
        throw NetworkingError.decodingFailed(error)
    }
}
