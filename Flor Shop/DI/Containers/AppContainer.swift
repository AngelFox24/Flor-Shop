import Foundation

final class AppContainer {
    static let shared = AppContainer()
    //Local Managers
    private let remoteSessionManager: RemoteSessionManager
    private let localSessionManager: LocalSessionManager
    private let localImageFileManager: LocalImageFileManager
    private let localImageManager: LocalImageManager
    private let remoteImageManager: RemoteImageManager
    //Repositories
    let sessionRepository: SessionRepository
    let imageRepository: ImageRepository
    init() {
        //Repo
        self.remoteSessionManager = RemoteSessionManagerImpl()
        self.localSessionManager = LocalSessionManagerImpl()
        self.sessionRepository = SessionRepositoryImpl(
            remoteManager: remoteSessionManager,
            localManager: localSessionManager
        )
        self.localImageFileManager = LocalImageFileManagerImpl()
        self.localImageManager = LocalImageManagerImpl(fileManager: localImageFileManager)
        self.remoteImageManager = RemoteImageManagerImpl()
        self.imageRepository = ImageRepositoryImpl(
            localManager: localImageManager,
            remoteManager: remoteImageManager
        )
    }
}
