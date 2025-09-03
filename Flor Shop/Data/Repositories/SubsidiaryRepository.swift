import Foundation
import CoreData

protocol SubsidiaryRepository: Syncronizable {
    func save(subsidiary: Subsidiary) async throws
    func getSubsidiaries() -> [Subsidiary]
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
    func getLastToken() -> Int64 {
        return 0
    }
    func getLastToken(context: NSManagedObjectContext) -> Int64 {
        return self.localManager.getLastToken(context: context)
    }
    func sync(backgroundContext: NSManagedObjectContext, syncDTOs: SyncClientParameters) async throws {
        try self.localManager.sync(backgroundContext: backgroundContext, subsidiariesDTOs: syncDTOs.subsidiaries)
    }
    func save(subsidiary: Subsidiary) async throws {
        if cloudBD {
            try await self.remoteManager.save(subsidiary: subsidiary)
        } else {
            try self.localManager.save(subsidiary: subsidiary)
        }
    }
    func getSubsidiaries() -> [Subsidiary] {
        return self.localManager.getSubsidiaries()
    }
}
