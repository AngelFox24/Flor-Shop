import Foundation
import CoreData

protocol CarRepository {
    func getCart() throws -> Car?
    func deleteCartDetail(cartDetail: CartDetail) throws
    func addProductoToCarrito(product: Product) throws
    func emptyCart() throws
    func changeProductAmountInCartDetail(productId: UUID, amount: Int) throws
}

class CarRepositoryImpl: CarRepository {
    let localManager: LocalCartManager
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
    func changeProductAmountInCartDetail(productId: UUID, amount: Int) throws {
        try self.localManager.changeProductAmountInCartDetail(productId: productId, amount: amount)
    }
}
