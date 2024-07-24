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
    private let logInUseCase: LogInUseCase
    private let logOutUseCase: LogOutUseCase
    
    init(logInUseCase: LogInUseCase, logOutUseCase: LogOutUseCase) {
        self.logInUseCase = logInUseCase
        self.logOutUseCase = logOutUseCase
    }
    
    func fieldsTrue() {
        print("All value true")
        logInFields.userOrEmailEdited = true
        logInFields.passwordEdited = true
    }
    func logIn() async -> SessionConfig? {
        do {
            return try await self.logInUseCase.execute(email: logInFields.userOrEmail, password: logInFields.password)
        } catch {
            await MainActor.run {
                self.logInFields.errorLogIn = error.localizedDescription
            }
            return nil
        }
    }
    func logOut() {
        self.logInStatus = .fail
        self.logOutUseCase.execute()
    }
    func checkDBIntegrity() {
        /*
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
        //Verificamos si existe la compañia por defecto del customer
        guard let customerCompanyDefaul: Company = self.customerRepository.getDefaultCompany() else {
            print("No se fijo la compañia en CustomerManager")
            return
        }
        if (companyDefaul.id == subsidiaryCompany.id) && (customerCompanyDefaul.id == companyDefaul.id) {
            if productSubsidiary.id == employeeSubsidiary.id {
                self.logInStatus = .success
            } else {
                print("productManager no coincide con employeeManager en Subsidiary Default")
            }
        } else {
            print("companyManager no coincide con subsidiaryManager en Company Default ni CustomerCompany")
        }
        */
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
