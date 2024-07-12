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
    init(manager: ProductManager) {
        self.localManager = manager
        self.remoteManager = RemoteProductManager()
    }
    func saveProduct(product: Product) async throws {
        guard let subsidiaryId = localManager.getDefaultSubsidiary()?.id else {
            throw APIError.invalidFields("El campo subsidiaryId no esta configurado")
        }
        if try await self.remoteManager.save(subsidiaryId: subsidiaryId, product: product) {
            try await sync()
            print("Exito Red, se guardo en local")
        } else {
            print("No se pudo guardar por red")
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
            let productRequest = ProductRequest(subsidiaryId: subsidiaryId, updatedSince: updatedSinceString)
            print("Se consultara a la API")
            let products = try await self.remoteManager.sync(productRequest: productRequest)
            print("Se obtuvo los productos exitosamente")
            items = products.count
            print("Items Sync: \(items)")
            for product in products {
                //TODO: Verificar respuesta y devolver error
                print("Se guardara en local \(product.name)")
                localManager.saveProduct(product: product)
            }
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
