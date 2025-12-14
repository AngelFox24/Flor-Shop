import Foundation
import CoreData
import FlorShopDTOs

enum RepositoryError: Error {
    case syncFailed(String)
    case invalidFields(String)
}

protocol ProductRepository: Syncronizable {
    func getLastToken() -> Int64
    func updateProducts(products: [Product]) -> [Product]
    func save(product: Product) async throws
    func getProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) -> [Product]
    func getProduct(productCic: String) throws -> Product
}

protocol Syncronizable {
    func sync(backgroundContext: NSManagedObjectContext, syncDTOs: SyncResponse) async throws
//    func getLastToken(context: NSManagedObjectContext) -> Int64
    func getLastToken() -> Int64
}

public class ProductRepositoryImpl: ProductRepository {
    let localManager: LocalProductManager
    let remoteManager: RemoteProductManager
    let cloudBD = true
    init(
        localManager: LocalProductManager,
        remoteManager: RemoteProductManager
    ) {
        self.localManager = localManager
        self.remoteManager = remoteManager
    }
    func save(product: Product) async throws {
        if cloudBD {
            try await self.remoteManager.save(product: product)
        } else {
            try self.localManager.save(product: product)
        }
    }
    func getLastToken() -> Int64 {
        self.localManager.getLastToken()
    }
    func getLastToken(context: NSManagedObjectContext) -> Int64 {
        self.localManager.getLastToken(context: context)
    }
    func sync(backgroundContext: NSManagedObjectContext, syncDTOs: SyncResponse) async throws {
        try self.localManager.sync(backgroundContext: backgroundContext, productsDTOs: syncDTOs.products)
    }
    func updateProducts(products: [Product]) -> [Product] {
        return localManager.updateProducts(products: products)
    }
    func getProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) -> [Product] {
        return localManager.getProducts(seachText: seachText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page, pageSize: pageSize)
    }
    func getProduct(productCic: String) throws -> Product {
        return try localManager.getProduct(productCic: productCic)
    }
}
