import Foundation
import CoreData
import FlorShop_DTOs

struct Company: Identifiable {
    var id: UUID
    let companyId: UUID?
    var companyName: String
    var ruc: String
}

extension Company {
    func toCompanyDTO() -> CompanyServerDTO {
        return CompanyServerDTO(
            id: companyId,
            companyName: companyName,
            ruc: ruc
        )
    }
}
