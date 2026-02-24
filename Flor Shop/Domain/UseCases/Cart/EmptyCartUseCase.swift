import Foundation

protocol EmptyCartUseCase {
    func execute() async throws
    func createCartIfNotExists() async throws
}

final class EmptyCartInteractor: EmptyCartUseCase {
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute() async throws {
        try await self.cartRepository.emptyCart()
    }
    
    func createCartIfNotExists() async throws {
        try await self.cartRepository.createCartIfNotExists()
    }
}
