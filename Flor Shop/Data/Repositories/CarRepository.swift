import Foundation

protocol CarRepository {
    func initializeModel() async throws
    func getCart() async throws -> Car?
    func deleteCartDetail(cartDetailId: UUID) async throws
    func addProductoToCarrito(productCic: String) async throws
    func addProductWithBarcode(barcode: String) async throws
    func emptyCart() async throws
    func stepProductAmountInCartDetail(cartDetailId: UUID, type: TypeOfVariation) async throws
    func changeProductAmountInCartDetail(cartDetailId: UUID, amount: Int) async throws
    func getCartQuantity() async throws -> Int
    func setCustomerInCart(customerCic: String?) async throws
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
    func addProductoToCarrito(productCic: String) async throws {
        try await self.localManager.addProductToCart(productCic: productCic)
    }
    func addProductWithBarcode(barcode: String) async throws {
        try await self.localManager.addProductWithBarcode(barcode: barcode)
    }
    func emptyCart() async throws {
        try await self.localManager.emptyCart()
    }
    func stepProductAmountInCartDetail(cartDetailId: UUID, type: TypeOfVariation) async throws {
        try await self.localManager.stepProductAmountInCartDetail(cartDetailId: cartDetailId, type: type)
    }
    func changeProductAmountInCartDetail(cartDetailId: UUID, amount: Int) async throws {
        try await self.localManager.changeProductAmountInCartDetail(cartDetailId: cartDetailId, amount: amount)
    }
    func getCartQuantity() async throws -> Int {
        return try await self.localManager.getCartQuantity()
    }
    func setCustomerInCart(customerCic: String?) async throws {
        return try await self.localManager.setCustomerInCart(customerCic: customerCic)
    }
}
