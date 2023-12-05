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
    func getListProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int) -> [Product]
    //func filterProducts(word: String) -> [Product]
    //func setOrder(order: PrimaryOrder)
    //func setFilter(filter: ProductsFilterAttributes)
    func setDefaultSubsidiary(subsidiary: Subsidiary)
    func getDefaultSubsidiary() -> Subsidiary?
}

public class ProductRepositoryImpl: ProductRepository {
    let manager: ProductManager
    // let remote:  remoto
    init(manager: ProductManager) {
        self.manager = manager
    }
    func saveProduct(product: Product) -> String {
        // add to remote logic
        return manager.saveProduct(product: product)
    }
    func getListProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int) -> [Product] {
        // add to remote logic
        return manager.getListProducts(seachText: seachText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page, pageSize: 20)
    }
    func setDefaultSubsidiary(subsidiary: Subsidiary) {
        self.manager.setDefaultSubsidiary(subsidiary: subsidiary)
    }
    func getDefaultSubsidiary() -> Subsidiary? {
        return self.manager.getDefaultSubsidiary()
    }
}
