//
//  ProductRepositoryImpl.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 20/05/23.

import Foundation

enum RepositoryError: Error {
    case syncFailed(String)
    case invalidFields(String)
}

protocol ProductRepository {
    func sync() async throws
    func saveProduct(product: Product) async throws
    func getProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) -> [Product]
}

protocol Syncronizable {
    func sync() async throws
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
    func saveProduct(product: Product) async throws {
        if cloudBD {
            try await self.remoteManager.save(product: product)
        } else {
            self.localManager.saveProduct(product: product)
        }
    }
    func sync() async throws {
        var counter = 0
        var items = 0
        
        repeat {
            print("Counter: \(counter)")
            counter += 1
            let updatedSinceString = ISO8601DateFormatter().string(from: localManager.getLastUpdated())
            let productsDTOs = try await self.remoteManager.sync(updatedSince: updatedSinceString)
            items = productsDTOs.count
            try self.localManager.sync(productsDTOs: productsDTOs)
        } while (counter < 10 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
    }
    func getProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) -> [Product] {
        return localManager.getProducts(seachText: seachText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page, pageSize: pageSize)
    }
}
