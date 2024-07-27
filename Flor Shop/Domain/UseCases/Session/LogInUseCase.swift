//
//  LogInUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation

protocol LogInUseCase {
    func execute(email: String, password: String) async throws -> SessionConfig
}

final class LogInRemoteInteractor: LogInUseCase {
    func execute(email: String, password: String) async throws -> SessionConfig {
        //TODO: Implement Remote Log In
        return SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
    }
}

final class LogInInteractor: LogInUseCase {
    func execute(email: String, password: String) async throws -> SessionConfig {
        return SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
    }
}
