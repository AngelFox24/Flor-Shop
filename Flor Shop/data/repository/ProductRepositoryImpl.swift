//
//  ProductRepositoryImpl.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 20/05/23.
//

import Foundation
import CoreData


//protocol
protocol ProductRepository {
    func saveProduct(product:Product)-> String
    func getListProducts() -> [Product]
    func reduceStock() -> Bool
    func filterProducts(word: String) -> [Product]
    func setPrimaryFilter(filter: PrimaryOrder)
}
//clas
public class ProductRepositoryImpl: ProductRepository {
    
    let manager : ProductManager
    //let remote:  remoto
    
    init(manager: ProductManager) {
        self.manager = manager
    }
    
    func saveProduct(product: Product) -> String {
        //add to remote logic
        return manager.saveProduct(product: product)
    }
    
    func getListProducts() -> [Product] {
        //add to remote logic
        return manager.getListProducts()
    }
    
    func reduceStock() -> Bool {
        //add to remote logic
        return manager.reduceStock()
    }
    
    func filterProducts(word: String) -> [Product] {
        return manager.filterProducts(word: word)
    }
    
    func setPrimaryFilter(filter: PrimaryOrder) {
        return manager.setPrimaryFilter(filter: filter)
    }
}
