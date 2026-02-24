import Foundation
import FlorShopDTOs

protocol SubsidiaryRepository {
    func save(subsidiary: Subsidiary) async throws
    func initialDataExist() async throws -> Bool
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
    func initialDataExist() async throws -> Bool {
        return try await self.localManager.initialDataExist()
    }
}
