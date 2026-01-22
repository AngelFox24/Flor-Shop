import Foundation
import FlorShopDTOs

enum FlorShopCoreApiRequest {
    case saveCompany(company: CompanyServerDTO, token: String)
    case saveCustomer(customer: CustomerServerDTO, token: String)
    case payCustomerDebt(params: PayCustomerDebtServerDTO, token: String)
    case saveEmployee(employee: EmployeeServerDTO, token: String)
    case isRegistrationComplete(token: String)
    case saveProduct(product: ProductServerDTO, token: String)
    case registerSale(sale: RegisterSaleParameters, token: String)
    case register(register: RegisterParameters, token: String)
    case saveSubsidiary(subsidiary: SubsidiaryServerDTO, token: String)
}

extension FlorShopCoreApiRequest: NetworkRequest {
    var url: URL? {
        let baseUrl = AppConfig.florShopCoreBaseURL
        let path: String
        switch self {
        case .saveCompany(_, let token):
            path = "/companies"
        case .saveCustomer(_, let token):
            path = "/customers"
        case .payCustomerDebt(_, let token):
            path = "/customer/payDebt"
        case .saveEmployee(_, let token):
            path = "/employees"
        case .isRegistrationComplete(let token):
            path = "/employees/isComplete"
        case .saveProduct(_, let token):
            path = "/products"
        case .registerSale(_, let token):
            path = "/sales"
        case .register(_, let token):
            path = "/session/register"
        case .saveSubsidiary(_, let token):
            path = "/subsidiaries"
        }
        let completePath = baseUrl + path
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
            headers[.authorization] = "Bearer \(scopedToken)"
        case .saveCustomer(_, let scopedToken):
            headers[.authorization] = "Bearer \(scopedToken)"
        case .payCustomerDebt(_, let scopedToken):
            headers[.authorization] = "Bearer \(scopedToken)"
        case .saveEmployee(_, let scopedToken):
            headers[.authorization] = "Bearer \(scopedToken)"
        case .isRegistrationComplete(let scopedToken):
            headers[.authorization] = "Bearer \(scopedToken)"
        case .saveProduct(_, let scopedToken):
            headers[.authorization] = "Bearer \(scopedToken)"
        case .registerSale(_, let scopedToken):
            headers[.authorization] = "Bearer \(scopedToken)"
        case .register(_, let scopedToken):
            headers[.authorization] = "Bearer \(scopedToken)"
        case .saveSubsidiary(_, let scopedToken):
            headers[.authorization] = "Bearer \(scopedToken)"
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
