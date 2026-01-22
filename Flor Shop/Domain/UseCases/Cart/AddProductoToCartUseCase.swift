import Foundation

protocol AddProductoToCartUseCase {
    func execute(product: Product) async throws
    func getCartQuantity() async throws -> Int
}

final class AddProductoToCartInteractor: AddProductoToCartUseCase {
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute(product: Product) async throws {
        try await self.cartRepository.addProductoToCarrito(product: product)
    }
    
    func getCartQuantity() async throws -> Int {
        return try await self.cartRepository.getCartQuantity()
    }
}
