import Foundation
import FlorShopDTOs

protocol RegisterSaleUseCase {
    func execute(cart: Car, paymentType: PaymentType, customerCic: String?) async throws
}

final class RegisterSaleInteractor: RegisterSaleUseCase {
    private let saleRepository: SaleRepository
    
    init(
        saleRepository: SaleRepository
    ) {
        self.saleRepository = saleRepository
    }
    
    func execute(cart: Car, paymentType: PaymentType, customerCic: String?) async throws {
        try await self.saleRepository.registerSale(cart: cart, paymentType: paymentType, customerCic: customerCic)
    }
}
