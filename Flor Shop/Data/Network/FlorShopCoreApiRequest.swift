import Foundation
import FlorShopDTOs

struct ScopedTokenWithSubdomain {
    let scopedToken: String
    let subdomain: String
}

enum FlorShopCoreApiRequest {
    case saveCompany(company: CompanyServerDTO, token: ScopedTokenWithSubdomain)
    case saveCustomer(customer: CustomerServerDTO, token: ScopedTokenWithSubdomain)
    case payCustomerDebt(params: PayCustomerDebtServerDTO, token: ScopedTokenWithSubdomain)
    case saveEmployee(employee: EmployeeServerDTO, token: ScopedTokenWithSubdomain)
    case isRegistrationComplete(token: ScopedTokenWithSubdomain)
    case saveProduct(product: ProductServerDTO, token: ScopedTokenWithSubdomain)
    case registerSale(sale: RegisterSaleParameters, token: ScopedTokenWithSubdomain)
    case register(register: RegisterParameters, token: ScopedTokenWithSubdomain)
    case saveSubsidiary(subsidiary: SubsidiaryServerDTO, token: ScopedTokenWithSubdomain)
}

extension FlorShopCoreApiRequest: NetworkRequest {
    var url: URL? {
        let baseUrl = AppConfig.florShopCoreBaseURL
        let path: String
        let subdomain: String
        switch self {
        case .saveCompany(_, let token):
            path = "/companies"
            subdomain = token.subdomain
        case .saveCustomer(_, let token):
            path = "/customers"
            subdomain = token.subdomain
        case .payCustomerDebt(_, let token):
            path = "/customer/payDebt"
            subdomain = token.subdomain
        case .saveEmployee(_, let token):
            path = "/employees"
            subdomain = token.subdomain
        case .isRegistrationComplete(let token):
            path = "/employees/isComplete"
            subdomain = token.subdomain
        case .saveProduct(_, let token):
            path = "/products"
            subdomain = token.subdomain
        case .registerSale(_, let token):
            path = "/sales"
            subdomain = token.subdomain
        case .register(_, let token):
            path = "/session/register"
            subdomain = token.subdomain
        case .saveSubsidiary(_, let token):
            path = "/subsidiaries"
            subdomain = token.subdomain
        }
        let newBaseUrl = baseUrl.replacingOccurrences(of: "{subdomain}", with: subdomain)
        let completePath = newBaseUrl + path
        return URL(string: completePath)
    }
    
    var method: HTTPMethod {
        switch self {
        case .saveCompany:
                .post
        case .saveCustomer:
                .post
        case .saveEmployee:
                .post
        case .isRegistrationComplete:
                .get
        case .payCustomerDebt:
                .post
        case .saveProduct:
                .post
        case .registerSale:
                .post
        case .register:
                .post
        case .saveSubsidiary:
                .post
        }
    }
    
    var headers: [HTTPHeader : String]? {
        var headers: [HTTPHeader: String] = [:]
        headers[.contentType] = ContentType.json.rawValue
        switch self {
        case .saveCompany(_, let scopedToken):
            headers[.authorization] = "Bearer \(scopedToken.scopedToken)"
        case .saveCustomer(_, let scopedToken):
            headers[.authorization] = "Bearer \(scopedToken.scopedToken)"
        case .payCustomerDebt(_, let scopedToken):
            headers[.authorization] = "Bearer \(scopedToken.scopedToken)"
        case .saveEmployee(_, let scopedToken):
            headers[.authorization] = "Bearer \(scopedToken.scopedToken)"
        case .isRegistrationComplete(let scopedToken):
            headers[.authorization] = "Bearer \(scopedToken.scopedToken)"
        case .saveProduct(_, let scopedToken):
            headers[.authorization] = "Bearer \(scopedToken.scopedToken)"
        case .registerSale(_, let scopedToken):
            headers[.authorization] = "Bearer \(scopedToken.scopedToken)"
        case .register(_, let scopedToken):
            headers[.authorization] = "Bearer \(scopedToken.scopedToken)"
        case .saveSubsidiary(_, let scopedToken):
            headers[.authorization] = "Bearer \(scopedToken.scopedToken)"
        }
        return headers
    }
    
    var parameters: (any Encodable)? {
        switch self {
        case .saveCompany(let company, _):
            return company
        case .saveCustomer(let customer, _):
            return customer
        case .payCustomerDebt(let params, _):
            return params
        case .saveEmployee(let employee, _):
            return employee
        case .isRegistrationComplete:
            return nil
        case .saveProduct(let product, _):
            return product
        case .registerSale(let sale, _):
            return sale
        case .register(let register, _):
            return register
        case .saveSubsidiary(let subsidiary, _):
            return subsidiary
        }
    }
}
