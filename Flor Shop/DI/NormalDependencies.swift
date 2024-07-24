//
//  NormalDependencies.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 22/07/2024.
//

import Foundation

struct NormalDependencies {
    let navManager: NavManager
    //Estados
    let loadingState: LoadingState
    let versionCheck: VersionCheck
    //Session UseCases
//    private let registerUserUseCase: RegisterUserUseCase
    private let logInUseCase: LogInUseCase
    private let logOutUseCase: LogOutUseCase
    //Session ViewModels
    let logInViewModel: LogInViewModel
//    let registrationViewModel: RegistrationViewModel
    init() {
        self.navManager = NavManager()
        //Estados
        self.loadingState = LoadingState()
        self.versionCheck = VersionCheck()
        //Session UseCases
        self.logInUseCase = LogInRemoteInteractor()
        self.logOutUseCase = LogOutRemoteInteractor()
        self.logInViewModel = LogInViewModel(logInUseCase: logInUseCase, logOutUseCase: logOutUseCase)
//        self.registrationViewModel = RegistrationViewModel(registerUserUseCase: <#T##any RegisterUserUseCase#>)
    }
}
