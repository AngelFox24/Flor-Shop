import Foundation
import FlorShopDTOs
import FlorShopNetworking

protocol RemoteAppConfigManager {
    func getAppConfig() async throws -> StableVersion
}

final class RemoteAppConfigManagerImpl: RemoteAppConfigManager {
    func getAppConfig() async throws -> StableVersion {
        let request = FlorShopPlatformApiRequest.getVersionStatus
        let config: AppConfigDTO = try await NetworkManager.shared.perform(request, decodeTo: AppConfigDTO.self)
        return config.toModel()
    }
}
