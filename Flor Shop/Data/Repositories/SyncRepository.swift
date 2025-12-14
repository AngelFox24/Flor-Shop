import Foundation
import CoreData
import FlorShopDTOs

protocol SyncRepository {
    func sync(globalSyncToken: Int64, branchSyncToken: Int64) async throws -> SyncResponse
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
    func sync(globalSyncToken: Int64, branchSyncToken: Int64) async throws -> SyncResponse {
        return try await self.remoteSyncManager.sync(globalSyncToken: globalSyncToken, branchSyncToken: branchSyncToken)
    }
}
