//
//  ProductRepositoryImpl.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 20/05/23.
// SS

import Foundation
import CoreData

protocol ProductRepository {
    func saveProduct(product: Product, subsidiary: Subsidiary) -> String
    func getListProducts() -> [Product]
    func reduceStock() -> Bool
    func filterProducts(word: String) -> [Product]
    func setOrder(order: PrimaryOrder)
    func setFilter(filter: ProductsFilterAttributes)
}

public class ProductRepositoryImpl: ProductRepository {
    let manager: ProductManager
    // let remote:  remoto
    init(manager: ProductManager) {
        self.manager = manager
    }
    func saveProduct(product: Product, subsidiary: Subsidiary) -> String {
        // add to remote logic
        return manager.saveProduct(product: product, subsidiary: subsidiary)
    }
    func getListProducts() -> [Product] {
        // add to remote logic
        return manager.getListProducts()
    }
    func reduceStock() -> Bool {
        // add to remote logic
        return manager.reduceStock()
    }
    func filterProducts(word: String) -> [Product] {
        return manager.filterProducts(word: word)
    }
    func setOrder(order: PrimaryOrder) {
        return manager.setOrder(order: order)
    }
    func setFilter(filter: ProductsFilterAttributes) {
        return manager.setFilter(filter: filter)
    }
}
