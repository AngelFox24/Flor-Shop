import Foundation

protocol DeleteCartDetailUseCase {
    func execute(cartDetailId: UUID) async throws
}

final class DeleteCartDetailInteractor: DeleteCartDetailUseCase {
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute(cartDetailId: UUID) async throws {
        try await self.cartRepository.deleteCartDetail(cartDetailId: cartDetailId)
    }
}
