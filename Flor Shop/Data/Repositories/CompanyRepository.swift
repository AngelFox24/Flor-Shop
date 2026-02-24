import Foundation
import FlorShopDTOs

protocol CompanyRepository {
    func save(company: Company) async throws
    func initialData() async throws
}

class CompanyRepositoryImpl: CompanyRepository {
    let remoteManager: RemoteCompanyManager
    let cloudBD = true
    init(
        remoteManager: RemoteCompanyManager
    ) {
        self.remoteManager = remoteManager
    }
    func save(company: Company) async throws {
        if cloudBD {
            try await self.remoteManager.save(company: company)
        }
    }
    func initialData() async throws {
        if cloudBD {
            try await self.remoteManager.initialData()
        }
    }
}
