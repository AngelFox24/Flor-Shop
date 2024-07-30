//
//  Networkmanager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/2024.
//

import Foundation
//import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    private let urlSession = URLSession.shared
    
    private init() {}
    
    func perform<T: Decodable>(_ request: NetworkRequest, decodeTo type: T.Type) async throws -> T {
            let urlRequest = try request.urlRequest()
            let (data, response) = try await urlSession.data(for: urlRequest)
            try processResponse(response: response)
            return try decodeData(data: data, type: T.self)
    }
    
    private func decodeData<T: Decodable>(data: Data, type: T.Type) throws -> T {
        do {
            let decodedObject = try JSONDecoder().decode(T.self, from: data)
            return decodedObject
        } catch let decodingError {
            throw NetworkError.decodingFailed(decodingError)
        }
    }
    
    private func processResponse(response: URLResponse?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 404:
            throw NetworkError.notFound
        case 500:
            throw NetworkError.internalServerError
        default:
            throw NetworkError.unknownError(statusCode: httpResponse.statusCode)
        }
    }
    
    func downloadFile(from url: URL) async throws -> URL {
            let (localURL, response) = try await urlSession.download(from: url)
            try processResponse(response: response)
            return localURL
    }
}
