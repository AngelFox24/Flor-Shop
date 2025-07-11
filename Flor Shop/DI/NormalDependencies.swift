//
//  NormalDependencies.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 22/07/2024.
//

import Foundation

struct NormalDependencies {
    //Session UseCases
    private let remoteSessionManager: RemoteSessionManager
    private let sessionRepository: SessionRepository
    private let logInUseCase: LogInUseCase
    private let registerUseCase: RegisterUseCase
    private let logOutUseCase: LogOutUseCase
    //Session ViewModels
    let logInViewModel: LogInViewModel
    let registrationViewModel: RegistrationViewModel
    init() {
        //Repo
        self.remoteSessionManager = RemoteSessionManagerImpl()
        self.sessionRepository = SessionRepositoryImpl(remoteManager: remoteSessionManager)
        //Session UseCases
        self.logInUseCase = LogInInteractor(sessionRepository: sessionRepository)
        self.registerUseCase = RegisterInteractor(sessionRepository: sessionRepository)
        self.logOutUseCase = LogOutRemoteInteractor()
        self.logInViewModel = LogInViewModel(logInUseCase: logInUseCase, logOutUseCase: logOutUseCase)
        self.registrationViewModel = RegistrationViewModel(registerUseCase: registerUseCase)
    }
}
