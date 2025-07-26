import Foundation
import FlorShop_DTOs
//MARK: Response Parameters
struct DefaultResponse: Decodable {
    let code: Int
    let message: String
}
struct PayCustomerDebtResponse: Decodable {
    let customerId: UUID
    let change: Int
}
//MARK: Sync Response Parameters
//struct SyncCompanyResponse: Decodable {
//    let companyDTO: CompanyDTO?
//    let syncIds: VerifySyncParameters
//}
//struct SyncCustomersResponse: Decodable {
//    let customersDTOs: [CustomerDTO]
//    let syncIds: VerifySyncParameters
//}
//struct SyncEmployeesResponse: Decodable {
//    let employeesDTOs: [EmployeeDTO]
//    let syncIds: VerifySyncParameters
//}
//struct SyncImageUrlResponse: Decodable {
//    let imagesUrlDTOs: [ImageURLDTO]
//    let syncIds: VerifySyncParameters
//}
//struct SyncProductsResponse: Decodable {
//    let productsDTOs: [ProductDTO]
//    let syncIds: VerifySyncParameters
//}
//struct SyncSalesResponse: Decodable {
//    let salesDTOs: [SaleDTO]
//    let syncIds: VerifySyncParameters
//}
//struct SyncSubsidiariesResponse: Decodable {
//    let subsidiariesDTOs: [SubsidiaryDTO]
//    let syncIds: VerifySyncParameters
//}
//MARK: SubResponse Parameters
struct VerifySyncParameters: Codable, Equatable {
    let imageLastUpdate: UUID
    let companyLastUpdate: UUID
    let subsidiaryLastUpdate: UUID
    let customerLastUpdate: UUID
    let productLastUpdate: UUID
    let employeeLastUpdate: UUID
    let saleLastUpdate: UUID
}

struct SyncClientParameters: Decodable {
    let images: [ImageURLClientDTO]
    let company: CompanyClientDTO?
    let subsidiaries: [SubsidiaryClientDTO]
    let employees: [EmployeeClientDTO]
    let customers: [CustomerClientDTO]
    let products: [ProductClientDTO]
    let sales: [SaleClientDTO]
    let salesDetail: [SaleDetailClientDTO]
    let lastToken: Int64
    let isUpToDate: Bool
}
