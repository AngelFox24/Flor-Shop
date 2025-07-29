import Foundation

protocol RemoteSessionManager {
    func logIn(username: String, password: String) async throws -> SessionConfig
    func register(registerParams: RegisterParameters) async throws -> SessionConfig
}

final class RemoteSessionManagerImpl: RemoteSessionManager {
    func logIn(username: String, password: String) async throws -> SessionConfig {
        let urlRoute = APIEndpoint.Session.login
        let logInParameters = LogInParameters(username: username, password: password)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: logInParameters)
        let data: SessionConfig = try await NetworkManager.shared.perform(request, decodeTo: SessionConfig.self)
        return data
    }
    func register(registerParams: RegisterParameters) async throws -> SessionConfig {
        let urlRoute = APIEndpoint.Session.register
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: registerParams)
        let data: SessionConfig = try await NetworkManager.shared.perform(request, decodeTo: SessionConfig.self)
        return data
    }
}
