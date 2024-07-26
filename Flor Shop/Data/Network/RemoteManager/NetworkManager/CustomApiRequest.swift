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
        return URL(string: "http://192.168.2.15:8080\(urlRoute)")
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

struct LoginParameters: Encodable {
    let userName: String
    let password: String
}

struct SyncFromSubsidiaryParameters: Encodable {
    let subsidiaryId: UUID
    let updatedSince: String
}

struct SyncFromCompanyParameters: Encodable {
    let companyId: UUID
    let updatedSince: String
}

struct SyncImageParameters: Encodable {
    let updatedSince: String
}

struct SyncCompanyParameters: Encodable {
    let updatedSince: String
}

struct DefaultResponse: Decodable {
    let code: Int
    let message: String
}
