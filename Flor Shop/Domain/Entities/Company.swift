import Foundation
import FlorShopDTOs

struct Company: Identifiable {
    var id: UUID
    var companyCic: String?
    var companyName: String
    var ruc: String
}

extension Company {
    func toCompanyDTO() -> CompanyServerDTO {
        return CompanyServerDTO(
            companyName: companyName,
            ruc: ruc
        )
    }
}
