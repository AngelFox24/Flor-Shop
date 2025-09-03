import Foundation

final class AppContainer {
    static let shared = AppContainer()
    //Local Managers
    private let remoteSessionManager: RemoteSessionManager
    private let localSessionManager: LocalSessionManager
    //Repositories
    let sessionRepository: SessionRepository
    init() {
        //Repo
        self.remoteSessionManager = RemoteSessionManagerImpl()
        self.localSessionManager = LocalSessionManagerImpl()
        self.sessionRepository = SessionRepositoryImpl(
            remoteManager: remoteSessionManager,
            localManager: localSessionManager
        )
    }
}
