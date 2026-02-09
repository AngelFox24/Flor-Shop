import Foundation

protocol AddProductoToCartUseCase {
    func execute(productCic: String) async throws
    func execute(barcode: String) async throws
    func getCartQuantity() async throws -> Int
}

final class AddProductoToCartInteractor: AddProductoToCartUseCase {
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute(productCic: String) async throws {
        try await self.cartRepository.addProductoToCarrito(productCic: productCic)
    }
    
    func execute(barcode: String) async throws {
        try await self.cartRepository.addProductWithBarcode(barcode: barcode)
    }
    
    func getCartQuantity() async throws -> Int {
        return try await self.cartRepository.getCartQuantity()
    }
}
