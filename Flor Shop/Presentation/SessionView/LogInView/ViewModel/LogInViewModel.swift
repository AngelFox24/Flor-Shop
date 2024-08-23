//
//  LogInViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 22/08/23.
//

import Foundation
import SwiftUI

enum LogInStatus {
    case success
    case fail
}

class LogInViewModel: ObservableObject {
//    @Published var logInStatus: LogInStatus = .success
    @Published var logInFields: LogInFields = LogInFields()
    @Published var businessDependencies: BusinessDependencies? = nil
    private let logInUseCase: LogInUseCase
    private let logOutUseCase: LogOutUseCase
    
    init(
        logInUseCase: LogInUseCase,
        logOutUseCase: LogOutUseCase
    ) {
        self.logInUseCase = logInUseCase
        self.logOutUseCase = logOutUseCase
    }
    
    func fieldsTrue() {
        print("All value true")
        logInFields.userOrEmailEdited = true
        logInFields.passwordEdited = true
    }
    func logIn() async throws -> SessionConfig {
        return try await self.logInUseCase.execute(username: self.logInFields.userOrEmail, password: self.logInFields.password)
    }
    func logOut() {
//        self.logInStatus = .fail
        self.logOutUseCase.execute()
    }
}

struct LogInFields {
    var userOrEmail: String = "angel.curi"
    var userOrEmailEdited: Bool = false
    var userOrEmailError: String {
        if userOrEmail == "" && userOrEmailEdited {
            return "Nombre de producto no válido"
        } else {
            return ""
        }
    }
    var password: String = "asd"
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
