//
//  ProductRepositoryImpl.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 20/05/23.

import Foundation
import CoreData

enum RepositoryError: Error {
    case syncFailed(String)
    case invalidFields(String)
}

protocol ProductRepository {
    func save(product: Product) async throws
    func getProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) -> [Product]
}

protocol Syncronizable {
    func sync(backgroundContext: NSManagedObjectContext, syncTokens: VerifySyncParameters) async throws -> VerifySyncParameters
}

public class ProductRepositoryImpl: ProductRepository, Syncronizable {
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
    func sync(backgroundContext: NSManagedObjectContext, syncTokens: VerifySyncParameters) async throws -> VerifySyncParameters {
        var counter = 0
        var items = 0
        var responseSyncTokens = syncTokens
        repeat {
            print("Counter: \(counter)")
            counter += 1
            let updatedSince = self.localManager.getLastUpdated()
            let response = try await self.remoteManager.sync(updatedSince: updatedSince, syncTokens: responseSyncTokens)
            items = response.productsDTOs.count
            responseSyncTokens = response.syncIds
            try self.localManager.sync(backgroundContext: backgroundContext, productsDTOs: response.productsDTOs)
        } while (counter < 200 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
        return responseSyncTokens
    }
    func getProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) -> [Product] {
        return localManager.getProducts(seachText: seachText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page, pageSize: pageSize)
    }
}
