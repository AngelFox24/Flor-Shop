import Foundation

protocol ChangeProductAmountInCartUseCase {
    func execute(productCic: String, amount: Int) throws
}

final class ChangeProductAmountInCartInteractor: ChangeProductAmountInCartUseCase {
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute(productCic: String, amount: Int) throws {
        print("ChangeProductAmountInCartUseCase: execute")
        try self.cartRepository.changeProductAmountInCartDetail(productCic: productCic, amount: amount)
    }
}
