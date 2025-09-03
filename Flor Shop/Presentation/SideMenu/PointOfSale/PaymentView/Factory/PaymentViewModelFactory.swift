import Foundation

struct PaymentViewModelFactory {
    static func getPaymentViewModel(sessionContainer: SessionContainer) -> PaymentViewModel {
        return PaymentViewModel(
            registerSaleUseCase: getRegisterSaleUseCase(sessionContainer: sessionContainer),
            getCartUseCase: getCartUseCase(sessionContainer: sessionContainer),
            emptyCartUseCase: getEmptyCartUseCase(sessionContainer: sessionContainer)
        )
    }
    static private func getCartUseCase(sessionContainer: SessionContainer) -> GetCartUseCase {
        return GetCartInteractor(cartRepository: sessionContainer.cartRepository)
    }
    static private func getEmptyCartUseCase(sessionContainer: SessionContainer) -> EmptyCartUseCase {
        return EmptyCartInteractor(cartRepository: sessionContainer.cartRepository)
    }
    static private func getRegisterSaleUseCase(sessionContainer: SessionContainer) -> RegisterSaleUseCase {
        return RegisterSaleInteractor(saleRepository: sessionContainer.salesRepository)
    }
}
