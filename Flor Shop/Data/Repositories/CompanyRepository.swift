//
//  CompanyRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol CompanyRepository {
    func save(company: Company) async throws
    func getSyncTokens(localTokens: VerifySyncParameters) async throws -> VerifySyncParameters
}

class CompanyRepositoryImpl: CompanyRepository, Syncronizable {
    let localManager: LocalCompanyManager
    let remoteManager: RemoteCompanyManager
    let cloudBD = true
    init(
        localManager: LocalCompanyManager,
        remoteManager: RemoteCompanyManager
    ) {
        self.localManager = localManager
        self.remoteManager = remoteManager
    }
    func sync(backgroundContext: NSManagedObjectContext, syncTokens: VerifySyncParameters) async throws -> VerifySyncParameters {
        var counter = 0
        var items = 0
        var responseSyncTokens = syncTokens
        repeat {
            print("Counter: \(counter)")
            counter += 1
            let updatedSince = self.localManager.getLastUpdated()
            let response = try await self.remoteManager.sync(updatedSince: updatedSince, syncTokens: responseSyncTokens)
            items = 1
            responseSyncTokens = response.syncIds
            if let companyDTO = response.companyDTO {
                try self.localManager.sync(backgroundContext: backgroundContext, companyDTO: companyDTO)
            }
        } while (counter < 10 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
        return responseSyncTokens
    }
    func save(company: Company) async throws {
        if cloudBD {
            try await self.remoteManager.save(company: company)
        } else {
            try self.localManager.save(company: company)
        }
    }
    func getSyncTokens(localTokens: VerifySyncParameters) async throws -> VerifySyncParameters {
        return try await self.remoteManager.getTokens(localTokens: localTokens)
    }
}
