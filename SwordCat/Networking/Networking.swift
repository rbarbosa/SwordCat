//
//  Networking.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import Foundation

enum NetworkingError: Error {
    case decodingFailed(Error)
    case invalidResponse
    case invalidURL
    case requestFailed(Error)
}

final class Networking {

    private enum APIURLComponents {
        static let scheme = "https"
        static let host = "api.thecatapi.com"
        static let path = "/v1/"
    }

    private let defaultHeaders: [String: String] = [
        "x-api-key": "live_qMFl2V4oA5s59ECGpAR5Wh15lD72XTdlZ12wMmtvoWI3sqyRKB1hkQ7z3pwb1KVU",
        "Content-Type": "application/json",
    ]

    func fetchURL(forQuery query: QueryType) async throws -> Data {
        guard let url = makeURL(fromQuery: query) else {
            throw NetworkingError.invalidURL
        }

        return try await fetchURL(url)
    }

    func fetchURL(_ url: URL) async throws -> Data {
        var urlRequest = URLRequest(url: url)

        defaultHeaders.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }

        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard
                let httpResponse = response as? HTTPURLResponse,
                200..<300 ~= httpResponse.statusCode
            else {
                throw NetworkingError.invalidResponse
            }

            return data
        } catch {
            throw NetworkingError.requestFailed(error)
        }
    }

    private func makeURL(fromQuery queryType: QueryType) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = APIURLComponents.scheme
        urlComponents.host = APIURLComponents.host
        urlComponents.path = APIURLComponents.path + queryType.path
        urlComponents.queryItems = queryType.queryItems

        return urlComponents.url
    }
}

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
