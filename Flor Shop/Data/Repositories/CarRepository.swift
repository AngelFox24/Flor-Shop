import Foundation

protocol CarRepository {
    func initializeModel() async throws
    func getCart() async throws -> Car?
    func deleteCartDetail(cartDetailId: UUID) async throws
    func addProductoToCarrito(product: Product) async throws
    func emptyCart() async throws
    func changeProductAmountInCartDetail(cartDetailId: UUID, productCic: String, amount: Int) async throws
    func getCartQuantity() async throws -> Int
}

class CarRepositoryImpl: CarRepository {
    let localManager: LocalCartManager
    init(
        localManager: LocalCartManager
    ) {
        self.localManager = localManager
    }
    func initializeModel() async throws {
        try await self.localManager.initializeModel()
    }
    func getCart() async throws -> Car? {
        return try await self.localManager.getCart()
    }
    func deleteCartDetail(cartDetailId: UUID) async throws {
        try await self.localManager.deleteCartDetail(cartDetailId: cartDetailId)
    }
    func addProductoToCarrito(product: Product) async throws {
        try await self.localManager.addProductToCart(productIn: product)
    }
    func emptyCart() async throws {
        try await self.localManager.emptyCart()
    }
    func changeProductAmountInCartDetail(cartDetailId: UUID, productCic: String, amount: Int) async throws {
        try await self.localManager.changeProductAmountInCartDetail(cartDetailId: cartDetailId, productCic: productCic, amount: amount)
    }
    func getCartQuantity() async throws -> Int {
        return try await self.localManager.getCartQuantity()
    }
}
