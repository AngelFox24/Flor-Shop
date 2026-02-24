import Foundation
import FlorShopDTOs

@Observable
final class RegistrationViewModel {
    var registrationFields: RegistrationFields = RegistrationFields()
    //Use Cases
    func fieldsTrue() {
        registrationFields.companyNameEdited = true
        registrationFields.companyRUCEdited = true
    }
    func registerUser(authProvider: AuthProvider, token: String) async throws -> RegisterStuffs {
        let newCompany = Company(
            id: UUID(),
            companyCic: nil,
            companyName: registrationFields.companyName,
            ruc: registrationFields.companyRUC
        )
//        let newSubsidiaryImage = ImageUrl(
//            id: UUID(),
//            imageUrl: "",
//            imageHash: "",
//            createdAt: Date(),
//            updatedAt: Date()
//        )
        let newSubsidiary = Subsidiary(
            id: UUID(),
            subsidiaryCic: nil,
            name: registrationFields.companyName,
            imageUrl: nil
        )
        return RegisterStuffs(
            company: newCompany,
            subsidiary: newSubsidiary,
            role: .manager,
            authProvider: authProvider,
            token: token
        )
    }
}
struct RegistrationFields {
    var companyName: String = ""
    var companyNameEdited: Bool = false
    var companyNameError: String {
        if self.companyName == "" && self.companyNameEdited {
            return "El nombre de la empresa no puede estar vacio"
        } else {
            return ""
        }
    }
    var companyRUC: String = ""
    var companyRUCEdited: Bool = false
    var companyRUCError: String {
        if self.companyRUC == "" && self.companyRUCEdited {
            return "RUC"
        } else {
            return ""
        }
    }
    
    var errorRegistration: String = ""
}
