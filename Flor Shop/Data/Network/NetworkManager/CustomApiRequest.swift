//
//  CustomApiRequest.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/2024.
//

import Foundation

struct CustomAPIRequest: NetworkRequest {
    var urlRoute: String
    var parameter: Encodable
    var sendMethod: HTTPMethod = .post
    var url: URL? {
        return URL(string: "https://pizzarely.mrangel.dev\(urlRoute)")
//        return URL(string: "http://192.168.2.5:8080\(urlRoute)")
    }
    var method: HTTPMethod {
        return sendMethod
    }
    var headers: [HTTPHeader: String]? {
        return [.contentType: ContentType.json.rawValue]
    }
    var parameters: Encodable? {
        return parameter
    }
}
