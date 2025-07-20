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
    func sync(backgroundContext: NSManagedObjectContext, syncDTOs: SyncClientParameters) async throws
    func getLastToken(context: NSManagedObjectContext) -> Int64
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
    func getLastToken(context: NSManagedObjectContext) -> Int64 {
        self.localManager.getLastToken(context: context)
    }
    func sync(backgroundContext: NSManagedObjectContext, syncDTOs: SyncClientParameters) async throws {
        try self.localManager.sync(backgroundContext: backgroundContext, productsDTOs: syncDTOs.products)
    }
    func getProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) -> [Product] {
        return localManager.getProducts(seachText: seachText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page, pageSize: pageSize)
    }
}
