import Foundation

@Observable
final class RegistrationViewModel {
    var registrationFields: RegistrationFields = RegistrationFields()
    func fieldsTrue() {
        registrationFields.subdomainEdited = true
        registrationFields.emailEdited = true
        registrationFields.companyNameEdited = true
        registrationFields.managerNameEdited = true
        registrationFields.managerLastNameEdited = true
        registrationFields.companyRUCEdited = true
    }
    func registerUser() async throws -> RegisterStuffs {
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
//        let newEmployeeImage = ImageUrl(
//            id: UUID(),
//            imageUrl: "",
//            imageHash: "",
//            createdAt: Date(),
//            updatedAt: Date()
//        )
        let newEmployee = Employee(
            id: UUID(),
            employeeCic: nil,
            name: registrationFields.managerName,
            email: registrationFields.email,
            lastName: registrationFields.managerLastName,
            role: .manager,
            imageUrl: nil,
            active: true,
            phoneNumber: ""
        )
        return RegisterStuffs(
            company: newCompany,
            subsidiary: newSubsidiary,
            employee: newEmployee,
            subdomain: registrationFields.subdomain
        )
    }
}
struct RegistrationFields {
    var subdomain: String = ""
    var subdomainEdited: Bool = false
    var subdomainError: String {
        if subdomain == "" && subdomainEdited {
            return "El subdominio no puede estar vacio"
        } else {
            return ""
        }
    }
    var email: String = "curilaurente@gmail.com"
    var emailEdited: Bool = false
    var emailError: String {
        if email == "" && emailEdited {
            return "El email no puede estar vacio"
        } else {
            return ""
        }
    }
    var companyName: String = "FlorShop"
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
    var managerName: String = "Manager"
    var managerNameEdited: Bool = false
    var managerNameError: String {
        if self.managerName == "" && self.managerNameEdited {
            return "El nombre del dueño no puede estar vacio"
        } else {
            return ""
        }
    }
    var managerLastName: String = "Last Name Manager"
    var managerLastNameEdited: Bool = false
    var managerLastNameError: String {
        if self.managerLastName == "" && self.managerLastNameEdited {
            return "Los apellidos del dueño no puede estar vacio"
        } else {
            return ""
        }
    }
    
    var errorRegistration: String = ""
}
