//
//  CarRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

protocol CarRepository {
    func getCar() -> Car
    func deleteProduct(product: Product)
    func addProductoToCarrito(product: Product)
    func emptyCart()
    func updateTotalCart()
    func increaceProductAmount (product: Product)
    func decreceProductAmount(product: Product)
}

class CarRepositoryImpl: CarRepository {
    let manager : CarManager
    //let remote:  remoto
    
    init(manager: CarManager) {
        self.manager = manager
    }
    
    func getCar() -> Car{
        return self.manager.getCar()
    }
    
    func deleteProduct(product: Product) {
        self.manager.deleteProduct(product: product)
    }
    
    func addProductoToCarrito(product: Product) {
        self.manager.addProductoToCarrito(product: product)
    }
    
    func emptyCart() {
        self.manager.emptyCart()
    }
    
    func updateTotalCart(){
        self.manager.updateTotalCart()
    }
    
    func increaceProductAmount (product: Product){
        self.manager.increaceProductAmount(product: product)
    }
    
    func decreceProductAmount(product: Product){
        self.manager.deleteProduct(product: product)
    }
}
