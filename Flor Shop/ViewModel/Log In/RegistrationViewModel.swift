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
    private let saleRepository: SaleRepository
    init(companyRepository: CompanyRepository, subsidiaryRepository: SubsidiaryRepository, employeeRepository: EmployeeRepository, cartRepository: CarRepository, productReporsitory: ProductRepository, saleRepository: SaleRepository) {
        self.companyRepository = companyRepository
        self.subsidiaryRepository = subsidiaryRepository
        self.employeeRepository = employeeRepository
        self.cartRepository = cartRepository
        self.productReporsitory = productReporsitory
        self.saleRepository = saleRepository
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
        //Ponemos como Default la Compañia, Sucursal y el Empleado, para que todos los cambios esten relacionados a estos
        if createCompany(company: companyRegistration) {
            setDefaultCompany(company: companyRegistration)
            if createSubsidiary(subsidiary: subsidiaryRegistration) {
                setDefaultSubsidiary(subsidiary: subsidiaryRegistration)
                if createEmployee(employee: userRegistration) {
                    setDefaultEmployee(employee: userRegistration)
                    return true
                } else {
                    registrationFields.errorRegistration = "Empleado ya existe en la BD"
                    return false
                }
            } else {
                registrationFields.errorRegistration = "Sucursal ya existe en la BD"
                return false
            }
        } else {
            registrationFields.errorRegistration = "Compañia ya existe en la BD"
            return false
        }
    }
    func createCompany(company: Company) -> Bool {
        return self.companyRepository.addCompany(company: company)
    }
    func createSubsidiary(subsidiary: Subsidiary) -> Bool {
        return self.subsidiaryRepository.addSubsidiary(subsidiary: subsidiary)
    }
    func createEmployee(employee: Employee) -> Bool {
        return self.employeeRepository.addEmployee(employee: employee)
    }
    func setDefaultCompany(company: Company) {
        self.companyRepository.setDefaultCompany(company: company)
        self.subsidiaryRepository.setDefaultCompany(company: company)
    }
    func setDefaultSubsidiary(subsidiary: Subsidiary) {
        self.productReporsitory.setDefaultSubsidiary(subsidiary: subsidiary)
        self.employeeRepository.setDefaultSubsidiary(subsidiary: subsidiary)
    }
    func setDefaultEmployee(employee: Employee) {
        self.cartRepository.setDefaultEmployee(employee: employee)
        // Creamos un carrito si no existe
        self.cartRepository.createCart()
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
