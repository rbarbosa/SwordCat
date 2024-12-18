//
//  ImagesRepositoryResponse.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import Foundation

struct ImagesRepositoryResponse {
    let breeds: [Breed]
}

// MARK: - Private structs to help decoding

private struct ImageResponse: Decodable {
    let url: String
    let breedsResponse: [BreedResponse]

    enum CodingKeys: String, CodingKey {
        case url
        case breedsResponse = "breeds"
    }
}

private struct BreedResponse: Decodable {
    let description: String
    let id: String
    let lifeSpan: String
    let name: String
    let origin: String
    let referenceImageId: String
    let temperament: String

    enum CodingKeys: String, CodingKey {
        case description
        case id
        case lifeSpan = "life_span"
        case name
        case origin
        case referenceImageId = "reference_image_id"
        case temperament
    }
}

func makeImagesRepositoryResponse(from data: Data) throws -> ImagesRepositoryResponse {
    do {
        let imagesResponse = try JSONDecoder().decode([ImageResponse].self, from: data)
        let breeds: [Breed] = imagesResponse.compactMap { imageResponse in
            guard
                let breedsResponse = imageResponse.breedsResponse.first,
                let imageUrl = URL(string: imageResponse.url)
            else {
                return nil
            }

            return .init(
                description: breedsResponse.description,
                id: breedsResponse.id,
                lifeSpan: breedsResponse.lifeSpan,
                name: breedsResponse.name,
                origin: breedsResponse.origin,
                referenceImageId: breedsResponse.referenceImageId,
                temperament: breedsResponse.temperament,
                url: imageUrl
            )
        }

        return .init(breeds: breeds)
    } catch {
        throw NetworkingError.decodingFailed(error)
    }
}
