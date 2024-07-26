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
    let localManager: LocalCartManager
    // let remote:  remoto
    init(
        localManager: LocalCartManager
    ) {
        self.localManager = localManager
    }
    func getCart() throws -> Car? {
        return try self.localManager.getCart()
    }
    func deleteCartDetail(cartDetail: CartDetail) {
        self.localManager.deleteCartDetail(cartDetail: cartDetail)
    }
    func addProductoToCarrito(product: Product) -> Bool {
        return self.localManager.addProductToCart(productIn: product)
    }
    func emptyCart() {
        self.localManager.emptyCart()
    }
    func updateCartTotal() {
        self.localManager.updateCartTotal()
    }
    func changeProductAmountInCartDetail(cartDetail: CartDetail) {
        self.localManager.changeProductAmountInCartDetail(productId: <#T##UUID#>, amount: <#T##Int#>)
    }
    func createCart() {
        self.localManager.createCart()
    }
}
