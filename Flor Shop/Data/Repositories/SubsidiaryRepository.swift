//
//  SubsidiaryRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol SubsidiaryRepository {
    func save(subsidiary: Subsidiary) async throws
    func getSubsidiaries() -> [Subsidiary]
}

class SubsidiaryRepositoryImpl: SubsidiaryRepository, Syncronizable {
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
    func sync(backgroundContext: NSManagedObjectContext, syncTokens: VerifySyncParameters) async throws -> VerifySyncParameters {
        var counter = 0
        var items = 0
        var responseSyncTokens = syncTokens
        repeat {
            counter += 1
            let updatedSince = self.localManager.getLastUpdated()
            let response = try await self.remoteManager.sync(updatedSince: updatedSince, syncTokens: responseSyncTokens)
            items = response.subsidiariesDTOs.count
            responseSyncTokens = response.syncIds
            print("Items Sync: \(items)")
            try self.localManager.sync(backgroundContext: backgroundContext, subsidiariesDTOs: response.subsidiariesDTOs)
        } while (counter < 10 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
        return responseSyncTokens
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
