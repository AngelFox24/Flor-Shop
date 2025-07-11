import Foundation

protocol RegisterUseCase {
    func execute(registerStuff: RegisterStuffs) async throws -> SessionConfig
}

final class RegisterInteractor: RegisterUseCase {
    
    private let sessionRepository: SessionRepository
    
    init(
        sessionRepository: SessionRepository
    ) {
        self.sessionRepository = sessionRepository
    }
    func execute(registerStuff: RegisterStuffs) async throws -> SessionConfig {
        return try await self.sessionRepository.register(registerStuff: registerStuff)
    }
}
