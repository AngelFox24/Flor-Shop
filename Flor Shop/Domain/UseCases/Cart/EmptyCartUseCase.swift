import Foundation

protocol EmptyCartUseCase {
    func execute() throws
}

final class EmptyCartInteractor: EmptyCartUseCase {
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute() throws {
        try self.cartRepository.emptyCart()
    }
}
