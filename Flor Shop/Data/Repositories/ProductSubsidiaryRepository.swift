import Foundation
import CoreData
import FlorShopDTOs

protocol ProductSubsidiaryRepository: Syncronizable {
}

public class ProductSubsidiaryRepositoryImpl: ProductSubsidiaryRepository {
    let localManager: LocalProductSubsidiaryManager
    init(
        localManager: LocalProductSubsidiaryManager
    ) {
        self.localManager = localManager
    }
    func getLastToken() -> Int64 {
        self.localManager.getLastToken()
    }
    func sync(backgroundContext: NSManagedObjectContext, syncDTOs: SyncResponse) async throws {
        try self.localManager.sync(backgroundContext: backgroundContext, productsSubsidiaryDTOs: syncDTOs.productsSubsidiary)
    }
}
