import Foundation

protocol ChangeProductAmountInCartUseCase {
    func execute(cartDetailId: UUID, amount: Int) async throws
    func stepProductAmount(cartDetailId: UUID, type: TypeOfVariation) async throws
}

final class ChangeProductAmountInCartInteractor: ChangeProductAmountInCartUseCase {
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute(cartDetailId: UUID, amount: Int) async throws {
        print("ChangeProductAmountInCartUseCase: execute")
        if amount == 0 {
            try await self.cartRepository.deleteCartDetail(cartDetailId: cartDetailId)
        } else {
            try await self.cartRepository.changeProductAmountInCartDetail(cartDetailId: cartDetailId, amount: amount)
        }
    }
    
    func stepProductAmount(cartDetailId: UUID, type: TypeOfVariation) async throws {
        try await self.cartRepository.stepProductAmountInCartDetail(cartDetailId: cartDetailId, type: type)
    }
}
