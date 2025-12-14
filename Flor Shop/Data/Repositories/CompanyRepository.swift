import Foundation
import CoreData
import FlorShopDTOs

protocol CompanyRepository: Syncronizable {
    func save(company: Company) async throws
}

class CompanyRepositoryImpl: CompanyRepository {
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
    func sync(backgroundContext: NSManagedObjectContext, syncDTOs: SyncResponse) async throws {
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
}
