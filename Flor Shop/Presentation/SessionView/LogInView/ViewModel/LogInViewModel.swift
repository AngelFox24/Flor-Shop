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
    @Published var logInStatus: LogInStatus = .fail
    @ObservedObject var logInFields: LogInFields = LogInFields()
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
        self.logInStatus = .fail
        self.logOutUseCase.execute()
    }
}

class LogInFields: ObservableObject {
    @Published var userOrEmail: String = "curilaurente@gmail.com"
    @Published var userOrEmailEdited: Bool = false
    var userOrEmailError: String {
        if userOrEmail == "" && userOrEmailEdited {
            return "Nombre de producto no válido"
        } else {
            return ""
        }
    }
    @Published var password: String = ""
    @Published var passwordEdited: Bool = false
    var passwordError: String {
        if self.password == "" && self.passwordEdited {
            return "Contraseña no válido"
        } else {
            return ""
        }
    }
    @Published var errorLogIn: String = ""
}
