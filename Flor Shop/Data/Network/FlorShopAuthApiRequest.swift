import Foundation
import FlorShopDTOs

enum FlorShopAuthApiRequest {
    case auth(provider: AuthProvider, providerToken: String)
    case getCompanies(baseToken: String)
    case getSubsidiaries(companyCic: String, baseToken: String)
    case selectSubsidiary(subsidiaryCic: String, baseToken: String)
    case registerCompany(request: RegisterCompanyRequest, providerToken: String)
    case registerInvitation(request: InvitationRequest, scopedToken: String)
    case refresh(request: RefreshTokenRequest)
}

extension FlorShopAuthApiRequest: NetworkRequest {
    var url: URL? {
        let baseUrl = AppConfig.florShopAuthBaseURL
        let path: String
        switch self {
        case .auth:
            path = "/auth"
        case .getCompanies:
            path = "/company"
        case .getSubsidiaries(let companyCic, _):
            path = "/subsidiary?companyCic=\(companyCic)"
        case .selectSubsidiary(let subsidiaryCic, _):
            path = "/subsidiary/selection?cic=\(subsidiaryCic)"
        case .registerCompany:
            path = "/company"
        case .registerInvitation:
            path = "/invitation"
        case .refresh:
            path = "/auth/refresh"
        }
        return URL(string: baseUrl + path)
    }
    
    var method: HTTPMethod {
        switch self {
        case .auth:
                .post
        case .getCompanies:
                .get
        case .getSubsidiaries:
                .get
        case .selectSubsidiary:
                .get
        case .registerCompany:
                .post
        case .registerInvitation:
                .post
        case .refresh:
                .post
        }
    }
    
    var headers: [HTTPHeader : String]? {
        var headers: [HTTPHeader: String] = [:]
        headers[.contentType] = ContentType.json.rawValue
        switch self {
        case .auth(_, let providerToken):
            headers[.authorization] = "Bearer \(providerToken)"
        case .getCompanies(let baseToken):
            headers[.authorization] = "Bearer \(baseToken)"
        case .getSubsidiaries(_, let baseToken):
            headers[.authorization] = "Bearer \(baseToken)"
        case .selectSubsidiary(_, let baseToken):
            headers[.authorization] = "Bearer \(baseToken)"
        case .registerCompany(_, let providerToken):
            headers[.authorization] = "Bearer \(providerToken)"
        case .registerInvitation(_, let scopedToken):
            headers[.authorization] = "Bearer \(scopedToken)"
        case .refresh:
            headers[.contentType] = ContentType.json.rawValue//TODO: Mejorar esto
        }
        return headers
    }
    
    var parameters: (any Encodable)? {
        switch self {
        case .auth(let provider, _):
            return ["provider": provider]
        case .getCompanies:
            return nil
        case .getSubsidiaries:
            return nil
        case .selectSubsidiary:
            return nil
        case .registerCompany(let request, _):
            return request
        case .registerInvitation(let request, _):
            return request
        case .refresh(let request):
            return request
        }
    }
}
