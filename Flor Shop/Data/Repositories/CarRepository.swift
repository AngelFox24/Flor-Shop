import Foundation

protocol CarRepository {
    func createCartIdNotExist() throws
    func getCart() throws -> Car?
    func deleteCartDetail(cartDetail: CartDetail) throws
    func addProductoToCarrito(product: Product) throws
    func emptyCart() throws
    func changeProductAmountInCartDetail(productCic: String, amount: Int) throws
    func getCartQuantity() throws -> Int
}

class CarRepositoryImpl: CarRepository {
    let localManager: LocalCartManager
    init(
        localManager: LocalCartManager
    ) {
        self.localManager = localManager
    }
    func createCartIdNotExist() throws {
        try self.localManager.createCartIdNotExist()
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
    func changeProductAmountInCartDetail(productCic: String, amount: Int) throws {
        try self.localManager.changeProductAmountInCartDetail(productCic: productCic, amount: amount)
    }
    func getCartQuantity() throws -> Int {
        return try self.localManager.getCartQuantity()
    }
}
