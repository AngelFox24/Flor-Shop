protocol CheckLatestVersionUseCase {
    func execute() async throws -> StableVersion
}

final class CheckLatestVersionInteractor: CheckLatestVersionUseCase {
    private let appConfigRepository: AppConfigRepository
    
    init(
        appConfigRepository: AppConfigRepository
    ) {
        self.appConfigRepository = appConfigRepository
    }
    func execute() async throws -> StableVersion {
        return try await self.appConfigRepository.getAppConfig()
    }
}
