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
    func reduceStock(carritoDeCompras: Car?) -> Bool
    func deleteProduct(indexSet: IndexSet) -> Bool
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
    
    func reduceStock(carritoDeCompras: Car?) -> Bool {
        //add to remote logic
        return manager.reduceStock(carritoDeCompras: carritoDeCompras)
    }
    
    func deleteProduct(indexSet: IndexSet) -> Bool {
        //add to remote logic
        return manager.deleteProduct(indexSet: indexSet)
    }
}
