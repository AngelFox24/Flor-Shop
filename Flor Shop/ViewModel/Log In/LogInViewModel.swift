//
//  LogInViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 22/08/23.
//

import Foundation

enum LogInStatus {
    case success
    case fail
}
class LogInViewModel: ObservableObject {
    @Published var logInStatus: LogInStatus = .fail
    @Published var logInFields: LogInFields = LogInFields()
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
        logInFields.userOrEmailEdited = true
        logInFields.passwordEdited = true
    }
    func logIn() {
        if let employee = employeeRepository.logIn(user: logInFields.userOrEmail, password: logInFields.password) {
            print("ok employee")
            setDefaultEmployee(employee: employee)
            if let subsidiary = getSubsidiary(employee: employee) {
                print("ok subsidiary")
                setDefaultSubsidiary(subsidiary: subsidiary)
                if let company = getCompany(subsidiary: subsidiary) {
                    print("ok company")
                    setDefaultCompany(company: company)
                } else {
                    print("Nok company")
                    logInFields.errorLogIn = "No se encontro compañia de la sucursal"
                }
            } else {
                print("Nok subsidiary")
                logInFields.errorLogIn = "No se encontro sucursal del empleado"
            }
        } else {
            print("Nok employee")
            logInFields.errorLogIn = "No se encontro usuario en la BD"
        }
    }
    func getSubsidiary(employee: Employee) -> Subsidiary? {
        return self.employeeRepository.getSubsidiary(employee: employee)
    }
    func getCompany(subsidiary: Subsidiary) -> Company? {
        return self.subsidiaryRepository.getCompany(subsidiary: subsidiary)
    }
    func setDefaultCompany(company: Company) {
        self.companyRepository.setDefaultCompany(company: company)
        self.subsidiaryRepository.setDefaultCompany(company: company)
    }
    func setDefaultSubsidiary(subsidiary: Subsidiary) {
        self.productReporsitory.setDefaultSubsidiary(subisidiary: subsidiary)
        self.employeeRepository.setDefaultSubsidiary(subisidiary: subsidiary)
    }
    func setDefaultEmployee(employee: Employee) {
        self.cartRepository.setDefaultEmployee(employee: employee)
        // Creamos un carrito si no existe
        self.cartRepository.createCart()
    }
    func checkDBIntegrity() {
        //Verficamos si existe un carrito del empleado default
        guard let _ = self.cartRepository.getCart() else {
            print("No se fijo el carrito LogInViewModel")
            return
        }
        //Verificamos si existe un empleado por defecto
        guard let _ = self.cartRepository.getDefaultEmployee() else {
            print("No se fijo el empleado en cartManager")
            return
        }
        //Verificamos si existe la sucursal del empleado por defecto
        guard let employeeSubsidiary: Subsidiary = self.employeeRepository.getDefaultSubsidiary() else {
            print("No se fijo la sucursal en employeeManager")
            return
        }
        //Verificamos si existe la sucursal del producto por defecto
        guard let productSubsidiary: Subsidiary = self.productReporsitory.getDefaultSubsidiary() else {
            print("No se fijo la sucursal en productManager")
            return
        }
        //Verificamos si existe la compañia de la sucursal por defecto
        guard let subsidiaryCompany: Company = self.subsidiaryRepository.getDefaulCompany() else {
            print("No se fijo la sucursal en subsidiaryManager")
            return
        }
        //Verificamos si existe la compañia por defecto
        guard let companyDefaul: Company = self.companyRepository.getDefaultCompany() else {
            print("No se fijo la compañia en companyManager")
            return
        }
        if companyDefaul.id == subsidiaryCompany.id {
            if productSubsidiary.id == employeeSubsidiary.id {
                self.logInStatus = .success
            } else {
                print("productManager no coincide con employeeManager en Subsidiary Default")
            }
        } else {
            print("companyManager no coincide con subsidiaryManager en Company Default")
        }
    }
}
class LogInFields {
    var userOrEmail: String = "curilaurente@gmail.com"
    var userOrEmailEdited: Bool = false
    var userOrEmailError: String {
        if userOrEmail == "" && userOrEmailEdited {
            return "Nombre de producto no válido"
        } else {
            return ""
        }
    }
    var password: String = ""
    var passwordEdited: Bool = false
    var passwordError: String {
        if self.password == "" && self.passwordEdited {
            return "Contraseña no válido"
        } else {
            return ""
        }
    }
    var errorLogIn: String = ""
}
