import Foundation
import FlorShopDTOs

struct StableVersion {
    let minimumVersion: String
    let latestVersion: String
    let forceUpdate: Bool
    let maintenanceMode: Bool
    let lastChecked: Date
}

extension AppConfigDTO {
    func toModel() -> StableVersion {
        return StableVersion(
            minimumVersion: self.minimumVersion,
            latestVersion: self.latestVersion,
            forceUpdate: self.forceUpdate,
            maintenanceMode: self.maintenanceMode,
            lastChecked: Date()
        )
    }
}
