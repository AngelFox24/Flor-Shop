//
//  RemoteSessionManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 31/07/2024.
//

import Foundation

protocol RemoteSessionManager {
    func logIn(username: String, password: String) async throws -> SessionConfig
}

final class RemoteSessionManagerImpl: RemoteSessionManager {
    func logIn(username: String, password: String) async throws -> SessionConfig {
        let urlRoute = "/session/logIn"
        let logInParameters = LogInParameters(username: username, password: password)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: logInParameters)
        let data: SessionConfig = try await NetworkManager.shared.perform(request, decodeTo: SessionConfig.self)
        return data
    }
}
