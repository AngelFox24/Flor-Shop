import Foundation
import FlorShopDTOs

protocol LogInUseCase {
    func execute(provider: AuthProvider, token: String) async throws
}

final class LogInInteractor: LogInUseCase {
    
    private let sessionRepository: SessionRepository
    
    init(
        sessionRepository: SessionRepository
    ) {
        self.sessionRepository = sessionRepository
    }
    func execute(provider: AuthProvider, token: String) async throws {
        try await self.sessionRepository.logIn(provider: provider, token: token)
    }
}
