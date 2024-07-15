//
//  ProductRepositoryImpl.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 20/05/23.
// SS

import Foundation
import CoreData

enum RepositoryError: Error {
    case syncFailed(String)
    case invalidFields(String)
}

protocol ProductRepository {
    func sync() async throws
    func saveProduct(product: Product) async throws
    func getListProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) -> [Product]
    //func filterProducts(word: String) -> [Product]
    //func setOrder(order: PrimaryOrder)
    //func setFilter(filter: ProductsFilterAttributes)
    func setDefaultSubsidiary(subsidiary: Subsidiary)
    func getDefaultSubsidiary() -> Subsidiary?
    func releaseResourses()
}

protocol Syncronizable {
    func sync() async throws
}

public class ProductRepositoryImpl: ProductRepository, Syncronizable {
    let localManager: ProductManager
    let remoteManager: RemoteProductManager
    let cloudBD = true
    init(manager: ProductManager) {
        self.localManager = manager
        self.remoteManager = RemoteProductManagerImpl()
    }
    func saveProduct(product: Product) async throws {
        if cloudBD {
            guard let subsidiaryId = localManager.getDefaultSubsidiary()?.id else {
                throw LocalStorageError.notFound("El campo subsidiaryId no esta configurado")
            }
            let productDTO = product.toProductDTO(subsidiaryId: subsidiaryId)
            try await self.remoteManager.save(productDTO: productDTO)
        } else {
            let _ = self.localManager.saveProduct(product: product)
        }
    }
    func sync() async throws {
        guard let subsidiaryId = localManager.getDefaultSubsidiary()?.id else {
            throw RepositoryError.invalidFields(("El campo subsidiaryId no esta configurado"))
        }
        var counter = 0
        var items = 0
        
        repeat {
            print("Counter: \(counter)")
            counter += 1
            guard let updatedSince = localManager.getLastUpdated() else {
                throw RepositoryError.invalidFields(("El campo updatedSince no se encuentra"))
            }
            let updatedSinceString = ISO8601DateFormatter().string(from: updatedSince)
            print("Se consultara a la API")
            let productsDTOs = try await self.remoteManager.sync(subsidiaryId: subsidiaryId, updatedSince: updatedSinceString)
            print("Se obtuvo los productos exitosamente")
            items = productsDTOs.count
            try self.localManager.sync(productsDTOs: productsDTOs)
        } while (counter < 10 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
    }
    func getListProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) -> [Product] {
        // add to remote logic
        return localManager.getListProducts(seachText: seachText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page, pageSize: pageSize)
    }
    func setDefaultSubsidiary(subsidiary: Subsidiary) {
        self.localManager.setDefaultSubsidiary(subsidiary: subsidiary)
    }
    func getDefaultSubsidiary() -> Subsidiary? {
        return self.localManager.getDefaultSubsidiary()
    }
    func releaseResourses() {
        self.localManager.releaseResourses()
    }
}
