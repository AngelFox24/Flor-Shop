//
//  NormalDependencies.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 22/07/2024.
//

import Foundation
import SwiftUI

struct NormalDependencies {
    let navManager: NavManager
    //Estados
    let errorState: ErrorState
    let versionCheck: VersionCheck
    let viewStates: ViewStates
    //Session UseCases
    let remoteSessionManager: RemoteSessionManager
    let sessionRepository: SessionRepository
//    private let registerUserUseCase: RegisterUserUseCase
    private let logInUseCase: LogInUseCase
    private let logOutUseCase: LogOutUseCase
    //Session ViewModels
    let logInViewModel: LogInViewModel
//    let registrationViewModel: RegistrationViewModel
    init() {
        self.navManager = NavManager()
        //Estados
        self.versionCheck = VersionCheck()
        self.errorState = ErrorState()
        self.viewStates = ViewStates()
        //Repo
        self.remoteSessionManager = RemoteSessionManagerImpl()
        self.sessionRepository = SessionRepositoryImpl(remoteManager: remoteSessionManager)
        //Session UseCases
        self.logInUseCase = LogInInteractor(sessionRepository: sessionRepository)
        self.logOutUseCase = LogOutRemoteInteractor()
        self.logInViewModel = LogInViewModel(logInUseCase: logInUseCase, logOutUseCase: logOutUseCase)
    }
}

class ErrorState: ObservableObject {
    @Published var isPresented: Bool = false
    var error: String = ""
    func processError(error: Error) {
        self.isPresented = true
        print("Error Description: \(error.localizedDescription)")
        self.error = "Un error inesperado"
    }
}

class ViewStates: ObservableObject {
    @Published var isShowMenu: Bool = false
    @Published var isLoading: Bool = false
}

