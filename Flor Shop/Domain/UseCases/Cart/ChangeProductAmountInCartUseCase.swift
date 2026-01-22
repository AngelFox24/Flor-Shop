import Foundation

protocol ChangeProductAmountInCartUseCase {
    func execute(cartDetailId: UUID, productCic: String, amount: Int) async throws
}

final class ChangeProductAmountInCartInteractor: ChangeProductAmountInCartUseCase {
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute(cartDetailId: UUID, productCic: String, amount: Int) async throws {
        print("ChangeProductAmountInCartUseCase: execute")
        try await self.cartRepository.changeProductAmountInCartDetail(cartDetailId: cartDetailId, productCic: productCic, amount: amount)
    }
}
