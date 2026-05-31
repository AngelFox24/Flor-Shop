import Foundation
import FlorShopDTOs
import FlorShopNetworking

enum FlorShopCoreApiRequest {
    case saveCompany(company: CompanyServerDTO, token: String)
    case saveCustomer(customer: CustomerServerDTO, token: String)
    case payCustomerDebt(params: PayCustomerDebtServerDTO, token: String)
    case saveEmployee(employee: EmployeeServerDTO, token: String)
    case isRegistrationComplete(token: String)
    case saveProduct(product: ProductServerDTO, token: String)
    case registerSale(sale: RegisterSaleParameters, token: String)
    case register(token: String)
    case saveSubsidiary(subsidiary: SubsidiaryServerDTO, token: String)
}

extension FlorShopCoreApiRequest: NetworkRequest {
    var url: URL? {
        let baseUrl = AppConfig.florShopCoreBaseURL
        let path: String
        switch self {
        case .saveCompany:
            path = "/companies"
        case .saveCustomer:
            path = "/customers"
        case .payCustomerDebt:
            path = "/customers/payDebt"
        case .saveEmployee:
            path = "/employees"
        case .isRegistrationComplete:
            path = "/employees/isComplete"
        case .saveProduct:
            path = "/products"
        case .registerSale:
            path = "/sales"
        case .register:
            path = "/session/register"
        case .saveSubsidiary:
            path = "/subsidiaries"
        }
        let completePath = baseUrl + path
        return URL(string: completePath)
    }
    
    var method: HTTPMethod {
        switch self {
        case .saveCompany, .saveCustomer, .saveEmployee, .payCustomerDebt, .saveProduct, .registerSale, .register, .saveSubsidiary:
                .post
        case .isRegistrationComplete:
                .get
        }
    }
    
    var headers: [HTTPHeader : String]? {
        var headers: [HTTPHeader: String] = [:]
        headers[.contentType] = ContentType.json.rawValue
        switch self {
        case .saveCompany(_, let scopedToken):
            headers[.scopedToken] = scopedToken
        case .saveCustomer(_, let scopedToken):
            headers[.scopedToken] = scopedToken
        case .payCustomerDebt(_, let scopedToken):
            headers[.scopedToken] = scopedToken
        case .saveEmployee(_, let scopedToken):
            headers[.scopedToken] = scopedToken
        case .isRegistrationComplete(let scopedToken):
            headers[.scopedToken] = scopedToken
        case .saveProduct(_, let scopedToken):
            headers[.scopedToken] = scopedToken
        case .registerSale(_, let scopedToken):
            headers[.scopedToken] = scopedToken
        case .register(let scopedToken):
            headers[.scopedToken] = scopedToken
        case .saveSubsidiary(_, let scopedToken):
            headers[.scopedToken] = scopedToken
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
        case .register(_):
            return nil
        case .saveSubsidiary(let subsidiary, _):
            return subsidiary
        }
    }
}
