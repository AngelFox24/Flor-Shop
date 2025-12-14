import Foundation
import CoreData
import FlorShopDTOs

protocol EmployeeSubsidiaryRepository: Syncronizable {
}

public class EmployeeSubsidiaryRepositoryImpl: EmployeeSubsidiaryRepository {
    let localManager: LocalEmployeeSubsidiaryManager
    init(
        localManager: LocalEmployeeSubsidiaryManager
    ) {
        self.localManager = localManager
    }
    func getLastToken() -> Int64 {
        self.localManager.getLastToken()
    }
    func sync(backgroundContext: NSManagedObjectContext, syncDTOs: SyncResponse) async throws {
        try self.localManager.sync(backgroundContext: backgroundContext, employeesSubsidiaryDTOs: syncDTOs.employeesSubsidiary)
    }
}
