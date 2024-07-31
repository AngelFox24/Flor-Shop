//
//  LogInUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation

protocol LogInUseCase {
    func execute(username: String, password: String) async throws -> SessionConfig
}

final class LogInInteractor: LogInUseCase {
    
    private let sessionRepository: SessionRepository
    
    init(
        sessionRepository: SessionRepository
    ) {
        self.sessionRepository = sessionRepository
    }
    func execute(username: String, password: String) async throws -> SessionConfig {
        return try await self.sessionRepository.logIn(username: username, password: password)
    }
}
