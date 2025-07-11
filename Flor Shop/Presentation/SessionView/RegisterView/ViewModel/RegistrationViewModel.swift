import Foundation
import Observation

@Observable
class RegistrationViewModel {
    var registrationFields: RegistrationFields = RegistrationFields()
    private let registerUseCase: RegisterUseCase
    init(
        registerUseCase: RegisterUseCase
    ) {
        self.registerUseCase = registerUseCase
    }
    func fieldsTrue() {
        registrationFields.emailEdited = true
        registrationFields.userEdited = true
        registrationFields.passwordEdited = true
        registrationFields.companyNameEdited = true
        registrationFields.managerNameEdited = true
        registrationFields.managerLastNameEdited = true
        registrationFields.companyRUCEdited = true
    }
    func registerUser() async throws -> SessionConfig {
        let newCompany = Company(
            id: UUID(),
            companyName: registrationFields.companyName,
            ruc: registrationFields.companyRUC,
            createdAt: Date(),
            updatedAt: Date()
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
            name: registrationFields.companyName,
            image: nil,
            createdAt: Date(),
            updatedAt: Date()
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
            name: registrationFields.managerName,
            user: registrationFields.user,
            email: registrationFields.email,
            lastName: registrationFields.managerLastName,
            role: "Manager",
            image: nil,
            active: true,
            phoneNumber: "",
            createdAt: Date(),
            updatedAt: Date()
        )
        return try await self.registerUseCase.execute(
            registerStuff: RegisterStuffs(
                company: newCompany,
                subsidiary: newSubsidiary,
                employee: newEmployee
            )
        )
    }
}
struct RegistrationFields {
    var email: String = "curilaurente@gmail.com"
    var emailEdited: Bool = false
    var emailError: String {
        if email == "" && emailEdited {
            return "El email no puede estar vacio"
        } else {
            return ""
        }
    }
    var user: String = "angel.curi"
    var userEdited: Bool = false
    var userError: String {
        if user == "" && userEdited {
            return "El nombre de usuario no puede estar vacio"
        } else {
            return ""
        }
    }
    var password: String = "password"
    var passwordEdited: Bool = false
    var passwordError: String {
        if self.password == "" && self.passwordEdited {
            return "Contraseña no válido"
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
