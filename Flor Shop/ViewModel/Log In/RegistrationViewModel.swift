//
//  RegistrationViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 22/08/23.
//

import Foundation

class RegistrationViewModel: ObservableObject {
    @Published var registrationFields: RegistrationFields = RegistrationFields()
    private let companyRepository: CompanyRepository
    private let subsidiaryRepository: SubsidiaryRepository
    private let employeeRepository: EmployeeRepository
    private let cartRepository: CarRepository
    private let productReporsitory: ProductRepository
    init(companyRepository: CompanyRepository, subsidiaryRepository: SubsidiaryRepository, employeeRepository: EmployeeRepository, cartRepository: CarRepository, productReporsitory: ProductRepository) {
        self.companyRepository = companyRepository
        self.subsidiaryRepository = subsidiaryRepository
        self.employeeRepository = employeeRepository
        self.cartRepository = cartRepository
        self.productReporsitory = productReporsitory
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
        let subsidiaryRegistration: Subsidiary = Subsidiary(id: UUID(), name: registrationFields.companyName, image: ImageUrl.getDummyImage())
        let userRegistration: Employee = Employee(id: UUID(), name: registrationFields.managerName, user: registrationFields.user, email: registrationFields.email, lastName: registrationFields.managerLastName, role: "Manager", image: ImageUrl.getDummyImage(), active: true)
        if companyRepository.addCompany(company: companyRegistration) {
            _ = createSubsidiary(subsidiary: subsidiaryRegistration, company: companyRegistration)
            _ = createEmployee(employee: userRegistration)
            createCart(employee: userRegistration)
            //Ponemos como Default la Compañia, Sucursal y el Empleado, para que todos los cambios esten relacionados a estos
            setDefaultCompany(employee: userRegistration)
            setDefaultSubsidiary(employee: userRegistration)
            setDefaultEmployee(employee: userRegistration)
            return true
        } else {
            registrationFields.errorRegistration = "Muchos errores pueden haber ocurrido"
            return false
        }
    }
    func createCart(employee: Employee) {
        self.cartRepository.createCart(employee: employee)
    }
    func setDefaultCompany(employee: Employee) {
        self.companyRepository.setDefaultCompany(employee: employee)
    }
    func createSubsidiary(subsidiary: Subsidiary, company: Company) -> Bool {
        return self.subsidiaryRepository.addSubsidiary(subsidiary: subsidiary, company: company)
    }
    func createEmployee(employee: Employee) -> Bool {
        return self.employeeRepository.addEmployee(employee: employee)
    }
    func setDefaultSubsidiary(employee: Employee) {
        self.subsidiaryRepository.setDefaultSubsidiary(employee: employee)
        self.productReporsitory.setDefaultSubsidiary(employee: employee)
    }
    func setDefaultEmployee(employee: Employee) {
        self.employeeRepository.setDefaultEmployee(employee: employee)
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
