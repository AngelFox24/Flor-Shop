import Foundation

struct SoftDIContainer {
    //Session UseCases
    private let remoteSessionManager: RemoteSessionManager
    private let sessionRepository: SessionRepository
    let logInUseCase: LogInUseCase
    let registerUseCase: RegisterUseCase
    let logOutUseCase: LogOutUseCase
    init() {
        //Repo
        self.remoteSessionManager = RemoteSessionManagerImpl()
        self.sessionRepository = SessionRepositoryImpl(remoteManager: remoteSessionManager)
        //Session UseCases
        self.logInUseCase = LogInInteractor(sessionRepository: sessionRepository)
        self.registerUseCase = RegisterInteractor(sessionRepository: sessionRepository)
        self.logOutUseCase = LogOutRemoteInteractor()
    }
}
