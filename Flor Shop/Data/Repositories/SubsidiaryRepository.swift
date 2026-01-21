import Foundation
import FlorShopDTOs

protocol SubsidiaryRepository {
    func save(subsidiary: Subsidiary) async throws
    func getSubsidiaries() async throws -> [Subsidiary]
}

class SubsidiaryRepositoryImpl: SubsidiaryRepository {
    let localManager: LocalSubsidiaryManager
    let remoteManager: RemoteSubsidiaryManager
    let cloudBD = true
    init(
        localManager: LocalSubsidiaryManager,
        remoteManager: RemoteSubsidiaryManager
    ) {
        self.localManager = localManager
        self.remoteManager = remoteManager
    }
    func save(subsidiary: Subsidiary) async throws {
        if cloudBD {
            try await self.remoteManager.save(subsidiary: subsidiary)
        }
    }
    func getSubsidiaries() async throws -> [Subsidiary] {
        return try await self.localManager.getSubsidiaries()
    }
}
