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
    func getLastToken() -> Int64 {
        return 0
    }
    func getLastToken(context: NSManagedObjectContext) -> Int64 {
        return self.localManager.getLastToken(context: context)
    }
    func sync(backgroundContext: NSManagedObjectContext, syncDTOs: SyncClientParameters) async throws {
        if let companyDTO = syncDTOs.company {
            try self.localManager.sync(backgroundContext: backgroundContext, companyDTO: companyDTO)
        }
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
