//
//  Cat.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import Foundation

struct Breed {
    let description: String
    let id: String
    let imageURLString: String
    let lifeSpan: String
    let name: String
    let temperament: String
    let url: URL
}

// MARK: - Mocks
#if DEBUG
extension Breed {
    static var mock: Self {
        .init(
            description: "The Abyssinian is easy to care for, and a joy to have in your home. They’re affectionate cats and love both people and other animals.",
            id: "abys",
            imageURLString: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg",
            lifeSpan: "14 - 15",
            name: "Abyssinian",
            temperament: "Active, Energetic, Independent, Intelligent, Gentle",
            url: URL(string: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg")!
        )
    }

    // TODO: - Add mock with local image 
}
#endif

