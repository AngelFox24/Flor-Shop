import Foundation

protocol RegisterSaleUseCase {
    func execute(cart: Car, paymentType: PaymentType, customerId: UUID?) async throws
}

final class RegisterSaleInteractor: RegisterSaleUseCase {
    private let saleRepository: SaleRepository
    
    init(
        saleRepository: SaleRepository
    ) {
        self.saleRepository = saleRepository
    }
    
    func execute(cart: Car, paymentType: PaymentType, customerId: UUID?) async throws {
        do {
            try await self.saleRepository.registerSale(cart: cart, paymentType: paymentType, customerId: customerId)
        } catch {
            throw error
        }
    }
}
