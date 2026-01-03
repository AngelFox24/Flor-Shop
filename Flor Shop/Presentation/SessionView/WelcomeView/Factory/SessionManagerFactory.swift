struct SessionManagerFactory {
    @MainActor static func getSessionManager() -> SessionManager {
        return SessionManager(
            sessionRepository: getSessionRepository()
        )
    }
    //Repositories
    static private func getSessionRepository() -> SessionRepository {
        return AppContainer.shared.sessionRepository
    }
}
