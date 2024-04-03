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
    func deleteCartDetail(cartDetail: CartDetail)
    func addProductoToCarrito(product: Product) -> Bool
    func emptyCart()
    func updateCartTotal()
    func increaceProductAmount (cartDetail: CartDetail)
    func decreceProductAmount(cartDetail: CartDetail)
    func getListProductInCart () -> [CartDetail]
    func createCart()
    func setDefaultEmployee(employee: Employee)
    func getDefaultEmployee() -> Employee?
    func releaseResourses()
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
    func deleteCartDetail(cartDetail: CartDetail) {
        self.manager.deleteCartDetail(cartDetail: cartDetail)
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
    func increaceProductAmount (cartDetail: CartDetail) {
        self.manager.increaceProductAmount(cartDetail: cartDetail)
    }
    func decreceProductAmount(cartDetail: CartDetail) {
        self.manager.decreceProductAmount(cartDetail: cartDetail)
    }
    func getListProductInCart () -> [CartDetail] {
        self.manager.getListProductInCart()
    }
    func createCart() {
        self.manager.createCart()
    }
    func setDefaultEmployee(employee: Employee) {
        self.manager.setDefaultEmployee(employee: employee)
    }
    func getDefaultEmployee() -> Employee? {
        return self.manager.getDefaultEmployee()
    }
    func releaseResourses() {
        self.manager.releaseResourses()
    }
}
