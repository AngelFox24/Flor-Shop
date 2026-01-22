import Foundation

protocol GetCartUseCase {
    func execute() async -> Car?
}

final class GetCartInteractor: GetCartUseCase {
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute() async -> Car? {
        do {
            return try await self.cartRepository.getCart()
        } catch {
            return nil
        }
    }
}
