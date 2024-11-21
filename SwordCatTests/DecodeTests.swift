//
//  DecodeTests.swift
//  SwordCatTests
//
//  Created by Rui Barbosa on 21/11/2024.
//

import Foundation
import Testing

@testable import SwordCat

struct DecodeTests {

    @Test("Decoding search images", .tags(.json))
    func decodeSearchImages() throws {
        let imagesJSON: Data = """
        [
            {
            "breeds": [
                {
                    "weight": {
                        "imperial": "5 - 9",
                        "metric": "2 - 4"
                    },
                    "id": "munc",
                    "name": "Munchkin",
                    "vetstreet_url": "http://www.vetstreet.com/cats/munchkin",
                    "temperament": "Agile, Easy Going, Intelligent, Playful",
                    "origin": "United States",
                    "country_codes": "US",
                    "country_code": "US",
                    "description": "The Munchkin is an outgoing cat who enjoys being handled.",
                    "life_span": "10 - 15",
                    "indoor": 0,
                    "lap": 1,
                    "alt_names": "",
                    "adaptability": 5,
                    "affection_level": 5,
                    "child_friendly": 4,
                    "dog_friendly": 5,
                    "energy_level": 4,
                    "grooming": 2,
                    "health_issues": 3,
                    "intelligence": 5,
                    "shedding_level": 3,
                    "social_needs": 5,
                    "stranger_friendly": 5,
                    "vocalisation": 3,
                    "experimental": 0,
                    "hairless": 0,
                    "natural": 0,
                    "rare": 0,
                    "rex": 0,
                    "suppressed_tail": 0,
                    "short_legs": 1,
                    "wikipedia_url": "https://en.wikipedia.org/wiki/Munchkin_(cat)",
                    "hypoallergenic": 0,
                    "reference_image_id": "j5cVSqLer"
                }
            ],
            "id": "a1g4Ycw-z",
            "url": "https://cdn2.thecatapi.com/images/a1g4Ycw-z.jpg",
            "width": 2407,
            "height": 2407
            }
        ]
        """.data(using: .utf8)!

        let imagesRepositoryResponse = try makeImagesRepositoryResponse(from: imagesJSON)

        #expect(imagesRepositoryResponse.breeds.count == 1)

        let breed = try #require(imagesRepositoryResponse.breeds.first)

        #expect(breed.id == "munc")
        #expect(breed.name == "Munchkin")
        #expect(breed.description == "The Munchkin is an outgoing cat who enjoys being handled.")
        #expect(breed.lifeSpan == "10 - 15")
        #expect(breed.temperament == "Agile, Easy Going, Intelligent, Playful")
        #expect(breed.url == URL(string: "https://cdn2.thecatapi.com/images/a1g4Ycw-z.jpg")!)
    }

    @Test("Decoding fetch breeds", .tags(.json))
    func decodeFetchBreed() throws {
        let breedsJSON: Data = """
        [
            {
                "weight": {
                    "imperial": "7  -  10",
                    "metric": "3 - 5"
                },
                "id": "abys",
                "name": "Abyssinian",
                "cfa_url": "http://cfa.org/Breeds/BreedsAB/Abyssinian.aspx",
                "vetstreet_url": "http://www.vetstreet.com/cats/abyssinian",
                "vcahospitals_url": "https://vcahospitals.com/know-your-pet/cat-breeds/abyssinian",
                "temperament": "Active, Energetic, Independent, Intelligent, Gentle",
                "origin": "Egypt",
                "country_codes": "EG",
                "country_code": "EG",
                "description": "The Abyssinian is easy to care for, and a joy to have in your home.",
                "life_span": "14 - 15",
                "indoor": 0,
                "lap": 1,
                "alt_names": "",
                "adaptability": 5,
                "affection_level": 5,
                "child_friendly": 3,
                "dog_friendly": 4,
                "energy_level": 5,
                "grooming": 1,
                "health_issues": 2,
                "intelligence": 5,
                "shedding_level": 2,
                "social_needs": 5,
                "stranger_friendly": 5,
                "vocalisation": 1,
                "experimental": 0,
                "hairless": 0,
                "natural": 1,
                "rare": 0,
                "rex": 0,
                "suppressed_tail": 0,
                "short_legs": 0,
                "wikipedia_url": "https://en.wikipedia.org/wiki/Abyssinian_(cat)",
                "hypoallergenic": 0,
                "reference_image_id": "0XYvRd7oD",
                "image": {
                    "id": "0XYvRd7oD",
                    "width": 1204,
                    "height": 1445,
                    "url": "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg"
                }
            }
        ]
        """.data(using: .utf8)!

        let breedsRepositoryResponse = try makeBreedsRepositoryResponse(from: breedsJSON)

        #expect(breedsRepositoryResponse.breeds.count == 1)

        let breed = try #require(breedsRepositoryResponse.breeds.first)

        #expect(breed.id == "abys")
        #expect(breed.name == "Abyssinian")
        #expect(breed.description == "The Abyssinian is easy to care for, and a joy to have in your home.")
        #expect(breed.lifeSpan == "14 - 15")
        #expect(breed.temperament == "Active, Energetic, Independent, Intelligent, Gentle")
        #expect(breed.url == URL(string: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg")!)
    }
}
