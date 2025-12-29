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

extension CompanyResponseDTO: @retroactive Equatable {
    public static func == (lhs: CompanyResponseDTO, rhs: CompanyResponseDTO) -> Bool {
        return lhs.company_cic == rhs.company_cic &&
               lhs.name == rhs.name &&
               lhs.subdomain == rhs.subdomain &&
               lhs.is_company_owner == rhs.is_company_owner
    }
}

extension CompanyResponseDTO: @retroactive Identifiable {
    public var id: String {
        return self.company_cic
    }
}

extension CompanyResponseDTO: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(company_cic)
    }
}

extension SubsidiaryResponseDTO: @retroactive Equatable {
    public static func == (lhs: SubsidiaryResponseDTO, rhs: SubsidiaryResponseDTO) -> Bool {
        return lhs.name == rhs.name &&
        lhs.subsidiary_cic == rhs.subsidiary_cic &&
        lhs.subsidiary_role == rhs.subsidiary_role
    }
}

extension SubsidiaryResponseDTO: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(subsidiary_cic)
    }
}

extension SubsidiaryResponseDTO: @retroactive Identifiable {
    public var id: String {
        return self.subsidiary_cic
    }
}
