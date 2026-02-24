import Foundation
import FlorShopDTOs

protocol AppConfigRepository {
    func getAppConfig() async throws -> StableVersion
}

class AppConfigRepositoryImpl: AppConfigRepository {
    let remoteManager: RemoteAppConfigManager
    let cloudBD = true
    init(
        remoteManager: RemoteAppConfigManager
    ) {
        self.remoteManager = remoteManager
    }
    func getAppConfig() async throws -> StableVersion {
        if cloudBD {
            try await self.remoteManager.getAppConfig()
        } else {
            throw LocalStorageError.invalidInput("No se verificar la version")
        }
    }
}
