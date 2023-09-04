//
//  CarRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

protocol CarRepository {
    func getCart() -> Car?
    func getCartEmployee() -> Employee?
    func deleteProduct(product: Product)
    func addProductoToCarrito(product: Product) -> Bool
    func emptyCart()
    func updateCartTotal()
    func increaceProductAmount (product: Product)
    func decreceProductAmount(product: Product)
    func getListProductInCart () -> [CartDetail]
    func createCart()
    func setDefaultEmployee(employee: Employee)
    func getDefaultEmployee() -> Employee?
}

class CarRepositoryImpl: CarRepository {
    let manager: CartManager
    // let remote:  remoto
    init(manager: CartManager) {
        self.manager = manager
    }
    func getCart() -> Car? {
        return self.manager.getCart()
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
    func createCart() {
        self.manager.createCart()
    }
    func getCartEmployee() -> Employee? {
        return self.manager.getCartEmployee()
    }
    func setDefaultEmployee(employee: Employee) {
        self.manager.setDefaultEmployee(employee: employee)
    }
    func getDefaultEmployee() -> Employee? {
        return self.manager.getDefaultEmployee()
    }
}
