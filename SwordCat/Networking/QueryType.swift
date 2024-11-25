//
//  QueryType.swift
//  SwordCat
//
//  Created by Rui Barbosa on 22/11/2024.
//

import Foundation

// MARK: - Query type

enum QueryType {
    case image(imageId: String)
    case breeds(page: Int)
    case searchBreed(String)
    case favorites

    var path: String {
        switch self {
        case .image(let imageId): "images/\(imageId)"
        case .breeds: "breeds"
        case .searchBreed: "breeds/search"
        case .favorites: "favourites"
        }
    }

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []

        switch self {
        case .image:
            break

        case .breeds(page: let page):
            items.append(.init(name: "page", value: String(page)))
            items.append(.init(name: "limit", value: "10"))

        case .searchBreed(let query):
            items.append(.init(name: "q", value: query))

        case .favorites:
            break
        }

        return items
    }
}

enum MutationQueryType {
    case markFavorite(MarkFavoriteInput)
    case unfavorite(favoriteId: Int)

    var path: String {
        switch self {
        case .markFavorite: 
            "favourites"

        case .unfavorite(let favoriteId):
            "favourites/\(favoriteId)"
        }
    }

    var httpMethod: String {
        switch self {
        case .markFavorite: "POST"
        case .unfavorite: "DELETE"
        }
    }

    func data() throws -> Data? {
        switch self {
        case .markFavorite(let input):
            try JSONEncoder().encode(input)

        case .unfavorite:
            nil
        }
    }
}
