//
//  QueryType.swift
//  SwordCat
//
//  Created by Rui Barbosa on 22/11/2024.
//

import Foundation

// MARK: - Query type

enum QueryType {
    case images(page: Int)
    case breeds(page: Int)
    case searchBreed(String)

    var path: String {
        switch self {
        case .images: "images/search"
        case .breeds: "breeds"
        case .searchBreed: "breeds/search"
        }
    }

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []

        switch self {
        case .images(page: let page):
            items.append(.init(name: "page", value: String(page)))
            items.append(.init(name: "limit", value: "10"))
            items.append(.init(name: "has_breeds", value: "1"))

        case .breeds(page: let page):
            items.append(.init(name: "page", value: String(page)))
            items.append(.init(name: "limit", value: "10"))

        case .searchBreed(let query):
            items.append(.init(name: "q", value: query))
        }

        return items
    }
}

enum MutationQueryType {
    case markFavorite(MarkFavoriteInput)

    var path: String {
        switch self {
        case .markFavorite: "favourites"
        }
    }

    func data() throws -> Data {
        switch self {
        case .markFavorite(let input):
            try JSONEncoder().encode(input)
        }
    }

}


