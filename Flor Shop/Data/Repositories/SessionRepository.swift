//
//  SessionRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 31/07/2024.
//

import Foundation

protocol SessionRepository {
    func logIn(username: String, password: String) async throws -> SessionConfig
}

class SessionRepositoryImpl: SessionRepository {
    let remoteManager: RemoteSessionManager
    let cloudBD = true
    init(
        remoteManager: RemoteSessionManager
    ) {
        self.remoteManager = remoteManager
    }
    func logIn(username: String, password: String) async throws -> SessionConfig {
        return try await self.remoteManager.logIn(username: username, password: password)
    }
}
