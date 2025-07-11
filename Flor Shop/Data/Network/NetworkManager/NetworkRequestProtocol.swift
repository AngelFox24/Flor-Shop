//
//  NetworkRequestProtocol.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/2024.
//

import Foundation

protocol NetworkRequest {
    var url: URL? { get }
    var method: HTTPMethod { get }
    var headers: [HTTPHeader: String]? { get }
    var parameters: Encodable? { get }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum HTTPHeader: String {
    case contentType = "Content-Type"
    case authorization = "Authorization"
}

enum ContentType: String {
    case json = "application/json"
    case xml = "application/xml"
    case formUrlEncoded = "application/x-www-form-urlencoded"
}

extension NetworkRequest {
    func urlRequest() throws -> URLRequest {
        guard let url = url else {
            throw NetworkError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key.rawValue)
            }
        }
        
        if let parameters = parameters {
            if method == .get {
                var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
                let parameterData = try JSONEncoder().encode(parameters)
                let parameterDictionary = try JSONSerialization.jsonObject(with: parameterData, options: []) as? [String: Any]
                urlComponents?.queryItems = parameterDictionary?.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                request.url = urlComponents?.url
            } else {
                do {
                    let jsonData = try JSONEncoder().encode(parameters)
                    print(jsonData.jsonString()) //TODO: Print Send Parameters Json -------------------------------------------------------------------------
                    request.httpBody = jsonData
                } catch {
                    throw NetworkError.encodingFailed(error)
                }
            }
        }
        
        return request
    }
}
