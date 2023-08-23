//
//  LogInViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 22/08/23.
//

import Foundation

class LogInViewModel: ObservableObject {
    @Published var logInFields: LogInFields = LogInFields()
    let subsidiaryRepository: SubsidiaryRepository
    let employeeRepository: EmployeeRepository
    let cartRepository: CarRepository
    let productReporsitory: ProductRepository
    init(subsidiaryRepository: SubsidiaryRepository, employeeRepository: EmployeeRepository, cartRepository: CarRepository, productReporsitory: ProductRepository) {
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
    func logIn() -> Bool {
        if let employee = employeeRepository.logIn(user: logInFields.userOrEmail, password: logInFields.password) {
            createCart(employee: employee)
            setDefaultSubsidiary(employee: employee)
            return true
        } else {
            logInFields.errorLogIn = "No se encontro usuario en la BD"
            return false
        }
    }
    func createCart(employee: Employee) {
        self.cartRepository.createCart(employee: employee)
    }
    func setDefaultSubsidiary(employee: Employee) {
        self.subsidiaryRepository.setDefaultSubsidiary(employee: employee)
        self.productReporsitory.setDefaultSubsidiary(employee: employee)
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
