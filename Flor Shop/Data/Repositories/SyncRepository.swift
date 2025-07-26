import Foundation
import CoreData

protocol SyncRepository {
    func sync(lastToken: Int64) async throws -> SyncClientParameters
}

class SyncRepositoryImpl: SyncRepository {
    let remoteSyncManager: RemoteSyncManager
    let cloudBD = true
    init(
        remoteSyncManager: RemoteSyncManager
    ) {
        self.remoteSyncManager = remoteSyncManager
    }
    //TODO: GetLastToken of local repositories from all entities
//    func getLastToken(context: NSManagedObjectContext) -> Int64 {
//        return self.localManager.getLastToken(context: context)
//    }
    func sync(lastToken: Int64) async throws -> SyncClientParameters {
        return try await self.remoteSyncManager.sync(lastToken: lastToken)
    }
}
