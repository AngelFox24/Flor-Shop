//
//  RegistrationViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 22/08/23.
//

import Foundation

class RegistrationViewModel: ObservableObject {
    @Published var registrationFields: RegistrationFields = RegistrationFields()
    private let registerUserUseCase: RegisterUserUseCase
    init(registerUserUseCase: RegisterUserUseCase) {
        self.registerUserUseCase = registerUserUseCase
    }
    func fieldsTrue() {
        print("All value true")
        registrationFields.emailEdited = true
        registrationFields.userEdited = true
        registrationFields.passwordEdited = true
        registrationFields.companyNameEdited = true
        registrationFields.managerNameEdited = true
        registrationFields.managerLastNameEdited = true
        registrationFields.companyRUCEdited = true
    }
    func registerUser() -> Bool {
        let companyRegistration: Company = Company(id: UUID(), companyName: registrationFields.companyName, ruc: registrationFields.companyRUC)
        let subsidiaryRegistration: Subsidiary = Subsidiary(id: UUID(), name: registrationFields.companyName, image: nil)
        let userRegistration: Employee = Employee(id: UUID(), name: registrationFields.managerName, user: registrationFields.user, email: registrationFields.email, lastName: registrationFields.managerLastName, role: "Manager", image: nil, active: true, phoneNumber: "")
        return self.registerUserUseCase.execute(company: companyRegistration, subsidiary: subsidiaryRegistration, employee: userRegistration)
    }
}
class RegistrationFields {
    var email: String = "curilaurente@gmail.com"
    var emailEdited: Bool = false
    var emailError: String {
        if email == "" && emailEdited {
            return "El email no puede estar vacio"
        } else {
            return ""
        }
    }
    var user: String = "Mrfox"
    var userEdited: Bool = false
    var userError: String {
        if user == "" && userEdited {
            return "El nombre de usuario no puede estar vacio"
        } else {
            return ""
        }
    }
    var password: String = "pro"
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
            return "Pon algo pz"
        } else {
            return ""
        }
    }
    var managerName: String = "Angel"
    var managerNameEdited: Bool = false
    var managerNameError: String {
        if self.managerName == "" && self.managerNameEdited {
            return "El nombre del dueño no puede estar vacio"
        } else {
            return ""
        }
    }
    var managerLastName: String = "Curi Laurente"
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
