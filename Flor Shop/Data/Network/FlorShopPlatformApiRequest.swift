import Foundation
import FlorShopDTOs

enum FlorShopPlatformApiRequest {
    case getVersionStatus
}

extension FlorShopPlatformApiRequest: NetworkRequest {
    var url: URL? {
        let baseUrl = AppConfig.florShopPlatformBaseURL
        let path: String
        switch self {
        case .getVersionStatus:
            path = "/appconfig?platform=\(Platform.iOS)"
        }
        return URL(string: baseUrl + path)
    }
    
    var method: HTTPMethod {
        switch self {
        case .getVersionStatus:
                .get
        }
    }
    
    var headers: [HTTPHeader : String]? {
        var headers: [HTTPHeader: String] = [:]
        headers[.contentType] = ContentType.json.rawValue
        return headers
    }
    
    var parameters: (any Encodable)? {
        switch self {
        case .getVersionStatus:
            return nil
        }
    }
}
