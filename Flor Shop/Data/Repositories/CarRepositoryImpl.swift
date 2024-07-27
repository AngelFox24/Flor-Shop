//
//  CarRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

protocol CarRepository {
    func getCart() throws -> Car?
    func deleteCartDetail(cartDetail: CartDetail) throws
    func addProductoToCarrito(product: Product) throws
    func emptyCart() throws
    func updateCartTotal() throws
    func changeProductAmountInCartDetail(cartDetail: CartDetail) throws
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
    func deleteCartDetail(cartDetail: CartDetail) throws {
        try self.localManager.deleteCartDetail(cartDetail: cartDetail)
    }
    func addProductoToCarrito(product: Product) throws {
        try self.localManager.addProductToCart(productIn: product)
    }
    func emptyCart() throws {
        try self.localManager.emptyCart()
    }
    func updateCartTotal() throws {
        try self.localManager.updateCartTotal()
    }
    func changeProductAmountInCartDetail(cartDetail: CartDetail) throws {
        try self.localManager.changeProductAmountInCartDetail(productId: cartDetail.product.id, amount: cartDetail.quantity)
    }
}
