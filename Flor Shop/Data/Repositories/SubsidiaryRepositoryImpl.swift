//
//  SubsidiaryRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol SubsidiaryRepository {
    func sync() async throws
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
    func sync() async throws {
        var counter = 0
        var items = 0
        repeat {
            counter += 1
            let updatedSinceString = ISO8601DateFormatter().string(from: localManager.getLastUpdated())
            let subsidiaresDTOs = try await self.remoteManager.sync(updatedSince: updatedSinceString)
            items = subsidiaresDTOs.count
            print("Items Sync: \(items)")
            try self.localManager.sync(subsidiariesDTOs: subsidiaresDTOs)
        } while (counter < 10 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
    }
    func save(subsidiary: Subsidiary) async throws {
        if cloudBD {
            try await self.remoteManager.save(subsidiary: subsidiary)
        } else {
            self.localManager.save(subsidiary: subsidiary)
        }
    }
    func getSubsidiaries() -> [Subsidiary] {
        return self.localManager.getSubsidiaries()
    }
}
