struct SessionManagerFactory {
    @MainActor static func getSessionManager() -> SessionManager {
        return SessionManager(
            storage: getSessionRepository()
        )
    }
    //UseCases
    static func getLogInUseCase() -> LogInUseCase {
        return LogInInteractor(
            sessionRepository: getSessionRepository()
        )
    }
    static func getLogOutUseCase() -> LogOutUseCase {
        return LogOutRemoteInteractor()
    }
    //Repositories
    static private func getSessionRepository() -> SessionRepository {
        return AppContainer.shared.sessionRepository
    }
}
