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

    func fetch(query: QueryType) async throws -> Data {
        guard let url = makeURL(fromQuery: query) else {
            throw NetworkingError.invalidURL
        }

        let urlRequest = URLRequest(url: url)

        return try await performURLRequest(urlRequest)

    }

    func perform(mutationQuery: MutationQueryType) async throws -> Data {
        guard let url = makeURL(fromMutationQuery: mutationQuery) else {
            throw NetworkingError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try mutationQuery.data()

        return try await performURLRequest(urlRequest)
    }

    private func performURLRequest(_ urlRequest: URLRequest) async throws -> Data {
        var request = urlRequest
        defaultHeaders.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

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

    private func makeURL(fromMutationQuery queryType: MutationQueryType) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = APIURLComponents.scheme
        urlComponents.host = APIURLComponents.host
        urlComponents.path = APIURLComponents.path + queryType.path

        return urlComponents.url
    }
}
