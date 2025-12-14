import Foundation
import FlorShopDTOs

extension CompanyClientDTO {
//    func toCompany() -> Company {
//        return Company(
//            id: UUID(),
//            companyCic: companyCic,
//            companyName: companyName,
//            ruc: ruc
//        )
//    }
    func isEquals(to other: Tb_Company) -> Bool {
        return (
            self.companyCic == other.companyCic &&
            self.companyName == other.companyName &&
            self.ruc == other.ruc &&
            self.syncToken == other.syncToken
        )
    }
}
