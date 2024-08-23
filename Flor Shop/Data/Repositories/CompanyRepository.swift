//
//  CompanyRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol CompanyRepository {
    func sync() async throws
    func save(company: Company) async throws
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
    func sync() async throws {
        var counter = 0
        var items = 0
        
        repeat {
            print("Counter: \(counter)")
            counter += 1
            let updatedSince = self.localManager.getLastUpdated()
            let companyDTO = try await self.remoteManager.sync(updatedSince: updatedSince)
            items = 1
            try self.localManager.sync(companyDTO: companyDTO)
        } while (counter < 10 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
    }
    func save(company: Company) async throws {
        if cloudBD {
            try await self.remoteManager.save(company: company)
        } else {
            try self.localManager.save(company: company)
        }
    }
}
