//
//  ProductRepositoryImpl.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 20/05/23.
// SS

import Foundation
import CoreData

protocol ProductRepository {
    func saveProduct(product: Product) -> String
    func getListProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) -> [Product]
    //func filterProducts(word: String) -> [Product]
    //func setOrder(order: PrimaryOrder)
    //func setFilter(filter: ProductsFilterAttributes)
    func setDefaultSubsidiary(subsidiary: Subsidiary)
    func getDefaultSubsidiary() -> Subsidiary?
}

public class ProductRepositoryImpl: ProductRepository {
    let localManager: ProductManager
    // let remote:  remoto
    init(manager: ProductManager) {
        self.localManager = manager
    }
    func saveProduct(product: Product) -> String {
        // add to remote logic
        return localManager.saveProduct(product: product)
    }
    func getListProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) -> [Product] {
        // add to remote logic
        /*
        var products: [Product] = []
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        self.remoteManager.getListMovies(page: page) { [weak self] downloadResult in
            switch downloadResult.result {
            case .success(let movies):
                moviesResult = movies
                dispatchGroup.leave()
            case .failure(let error):
                moviesResult = localManager.getListProducts(seachText: seachText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page, pageSize: 20)
                print("Error Network: \(error)")
                dispatchGroup.leave()
            }
        }
        dispatchGroup.wait()
        return moviesResult
         */
        return localManager.getListProducts(seachText: seachText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page, pageSize: pageSize)
    }
    func setDefaultSubsidiary(subsidiary: Subsidiary) {
        self.localManager.setDefaultSubsidiary(subsidiary: subsidiary)
    }
    func getDefaultSubsidiary() -> Subsidiary? {
        return self.localManager.getDefaultSubsidiary()
    }
}
