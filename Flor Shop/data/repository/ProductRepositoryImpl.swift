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
    func getListProducts() -> [Product]
    func reduceStock(cartDetails: [CartDetail]) -> Bool
    func filterProducts(word: String) -> [Product]
    func setOrder(order: PrimaryOrder)
    func setFilter(filter: ProductsFilterAttributes)
    func setDefaultSubsidiary(subisidiary: Subsidiary)
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
    func getListProducts() -> [Product] {
        // add to remote logic
        return manager.getListProducts()
    }
    func reduceStock(cartDetails: [CartDetail]) -> Bool {
        // add to remote logic
        return manager.reduceStock(cartDetails: cartDetails)
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
    func setDefaultSubsidiary(subisidiary: Subsidiary) {
        self.manager.setDefaultSubsidiary(subisidiary: subisidiary)
    }
    func getDefaultSubsidiary() -> Subsidiary? {
        return self.manager.getDefaultSubsidiary()
    }
}
