import Foundation
import FlorShopDTOs

enum FlorShopImagesApiRequest {
    case saveImage(image: ImageServerDTO)
}

extension FlorShopImagesApiRequest: NetworkRequest {
    var url: URL? {
        let baseUrl = AppConfig.florShopImagesBaseURL
        let path: String
        switch self {
        case .saveImage:
            path = "/image"
        }
        return URL(string: baseUrl + path)
    }
    
    var method: HTTPMethod {
        switch self {
        case .saveImage:
                .post
        }
    }
    
    var headers: [HTTPHeader : String]? {
        var headers: [HTTPHeader: String] = [:]
        headers[.contentType] = ContentType.json.rawValue
        return headers
    }
    
    var parameters: (any Encodable)? {
        switch self {
        case .saveImage(let imageDTO):
            return imageDTO
        }
    }
}
