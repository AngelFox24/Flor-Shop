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
    func addProductoToCarrito(product: Product) -> Bool
    func emptyCart()
    func updateCartTotal()
    func increaceProductAmount (product: Product)
    func decreceProductAmount(product: Product)
    func getListProductInCart () -> [CartDetail]
}

class CarRepositoryImpl: CarRepository {
    let manager: CarManager
    // let remote:  remoto
    init(manager: CarManager) {
        self.manager = manager
    }
    func getCar() -> Car {
        return self.manager.getCar()
    }
    func deleteProduct(product: Product) {
        self.manager.deleteProduct(product: product)
    }
    func addProductoToCarrito(product: Product) -> Bool {
        return self.manager.addProductToCart(productIn: product)
    }
    func emptyCart() {
        self.manager.emptyCart()
    }
    func updateCartTotal() {
        self.manager.updateCartTotal()
    }
    func increaceProductAmount (product: Product) {
        self.manager.increaceProductAmount(product: product)
    }
    func decreceProductAmount(product: Product) {
        self.manager.decreceProductAmount(product: product)
    }
    func getListProductInCart () -> [CartDetail] {
        self.manager.getListProductInCart()
    }
}
