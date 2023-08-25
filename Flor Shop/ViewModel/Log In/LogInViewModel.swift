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
            createCart(employee: employee)
            //Ponemos como Default la Compañia, Sucursal y el Empleado, para que todos los cambios esten relacionados a estos
            setDefaultCompany(employee: employee)
            setDefaultSubsidiary(employee: employee)
            setDefaultEmployee(employee: employee)
            //self.logInStatus = .success
        } else {
            logInFields.errorLogIn = "No se encontro usuario en la BD"
            self.logInStatus = .fail
        }
    }
    func createCart(employee: Employee) {
        self.cartRepository.createCart(employee: employee)
    }
    func setDefaultCompany(employee: Employee) {
        self.companyRepository.setDefaultCompany(employee: employee)
    }
    func setDefaultSubsidiary(employee: Employee) {
        self.subsidiaryRepository.setDefaultSubsidiary(employee: employee)
        self.productReporsitory.setDefaultSubsidiary(employee: employee)
    }
    func setDefaultEmployee(employee: Employee) {
        self.employeeRepository.setDefaultEmployee(employee: employee)
    }
    func checkDBIntegrity() {
        guard let _ = self.cartRepository.getCart() else {
            print("No se fijo el carrito")
            return
        }
        guard let employee = self.employeeRepository.getEmployee() else {
            print("No se fijo el empleado")
            return
        }
        guard let subsidiary = self.subsidiaryRepository.getSubsidiary() else {
            print("No se fijo la sucursal")
            return
        }
        guard let company = self.companyRepository.getCompany() else {
            print("No se fijo la compañia")
            return
        }
        guard let cartEmployee = self.cartRepository.getCartEmployee() else {
            print("Carrito no pertenece a un empleado")
            return
        }
        guard let employeeSubsidiary = self.employeeRepository.getEmployeeSubsidiary() else {
            print("Empleado no tiene sucursal")
            return
        }
        guard let subsidiaryCompany = self.subsidiaryRepository.getSubsidiaryCompany() else {
            print("La sucursar no tiene compañia")
            return
        }
        if subsidiary.id != employeeSubsidiary.id {
            print("Empleado no pertenece a esta sucursal \(employeeSubsidiary.name) y \(subsidiary.name)")
        } else if company.id != subsidiaryCompany.id {
            print("Sucursal no pertenece a esta compañia \(company.companyName) y \(subsidiaryCompany.companyName)")
        } else if employee.id != cartEmployee.id {
            print("Carrito no pertenece a este empleado \(employee.name) y \(cartEmployee.name)")
        } else {
            self.logInStatus = .success
        }
    }
}
class LogInFields {
    var userOrEmail: String = ""
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
