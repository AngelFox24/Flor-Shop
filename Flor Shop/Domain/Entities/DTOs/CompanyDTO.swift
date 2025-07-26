import Foundation
import FlorShop_DTOs

extension CompanyClientDTO {
    func toCompany() -> Company {
        return Company(
            id: id,
            companyId: id,
            companyName: companyName,
            ruc: ruc
        )
    }
    func isEquals(to other: Tb_Company) -> Bool {
        return (
            self.id == other.idCompany &&
            self.companyName == other.companyName &&
            self.ruc == other.ruc &&
            self.syncToken == other.syncToken
        )
    }
}
