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
    func addSubsidiary(subsidiary: Subsidiary) async throws
    func getSubsidiaries() -> [Subsidiary]
    func updateSubsidiary(subsidiary: Subsidiary)
    func deleteSubsidiary(subsidiary: Subsidiary)
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
            guard let updatedSince = try localManager.getLastUpdated() else {
                throw RepositoryError.invalidFields(("El campo updatedSince no se encuentra"))
            }
            let updatedSinceString = ISO8601DateFormatter().string(from: updatedSince)
            let subsidiaresDTOs = try await self.remoteManager.sync(updatedSince: updatedSinceString)
            items = subsidiaresDTOs.count
            print("Items Sync: \(items)")
            try self.localManager.sync(subsidiariesDTOs: subsidiaresDTOs)
        } while (counter < 10 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
    }
    //C - Create
    func addSubsidiary(subsidiary: Subsidiary) async throws {
        if cloudBD {
            try await self.remoteManager.save(subsidiary: subsidiary)
        } else {
            self.localManager.addSubsidiary(subsidiary: subsidiary)
        }
    }
    //R - Read
    func getSubsidiaries() -> [Subsidiary] {
        return self.localManager.getSubsidiaries()
    }
    //U - Update
    func updateSubsidiary(subsidiary: Subsidiary) {
        self.localManager.updateSubsidiary(subsidiary: subsidiary)
    }
    //D - Delete
    func deleteSubsidiary(subsidiary: Subsidiary) {
        self.localManager.deleteSubsidiary(subsidiary: subsidiary)
    }
}
