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
    func getListProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) throws -> [Product]
}

protocol Syncronizable {
    func sync() async throws
}

public class ProductRepositoryImpl: ProductRepository, Syncronizable {
    let localManager: ProductManager
    let remoteManager: RemoteProductManager
    let cloudBD = true
    init(
        localProductManager: ProductManager,
        remoteProductManager: RemoteProductManager
    ) {
        self.localManager = localProductManager
        self.remoteManager = remoteProductManager
    }
    func saveProduct(product: Product) async throws {
        if cloudBD {
            try await self.remoteManager.save(product: product)
        } else {
            let _ = try self.localManager.saveProduct(product: product)
        }
    }
    func sync() async throws {
        var counter = 0
        var items = 0
        
        repeat {
            print("Counter: \(counter)")
            counter += 1
            guard let updatedSince = try localManager.getLastUpdated() else {
                throw RepositoryError.invalidFields(("El campo updatedSince no se encuentra"))
            }
            let updatedSinceString = ISO8601DateFormatter().string(from: updatedSince)
            print("Se consultara a la API")
            let products = try await self.remoteManager.sync(updatedSince: updatedSinceString)
            print("Se obtuvo los productos exitosamente")
            items = products.count
            try self.localManager.sync(products: products)
        } while (counter < 10 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
    }
    func getListProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) throws -> [Product] {
        return try localManager.getListProducts(seachText: seachText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page, pageSize: pageSize)
    }
}
