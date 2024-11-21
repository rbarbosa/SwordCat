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



}
