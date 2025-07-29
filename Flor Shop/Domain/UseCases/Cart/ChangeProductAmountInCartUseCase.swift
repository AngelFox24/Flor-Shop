import Foundation

protocol ChangeProductAmountInCartUseCase {
    func execute(productId: UUID, amount: Int) throws
}

final class ChangeProductAmountInCartInteractor: ChangeProductAmountInCartUseCase {
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute(productId: UUID, amount: Int) throws {
        print("ChangeProductAmountInCartUseCase: execute")
        try self.cartRepository.changeProductAmountInCartDetail(productId: productId, amount: amount)
    }
}
