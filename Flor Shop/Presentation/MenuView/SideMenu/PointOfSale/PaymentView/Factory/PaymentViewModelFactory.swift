import Foundation

struct PaymentViewModelFactory {
    static func getPaymentViewModel(sessionContainer: SessionContainer) -> PaymentViewModel {
        return PaymentViewModel(
            registerSaleUseCase: getRegisterSaleUseCase(sessionContainer: sessionContainer),
            getCartUseCase: getCartUseCase(sessionContainer: sessionContainer),
            emptyCartUseCase: getEmptyCartUseCase(sessionContainer: sessionContainer),
            getCustomersUseCase: getRegisterSaleUseCase(sessionContainer: sessionContainer),
            setCustomerInCartUseCase: getSetCustomerInCartUserCase(sessionContainer: sessionContainer)
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
    static private func getRegisterSaleUseCase(sessionContainer: SessionContainer) -> GetCustomersUseCase {
        return GetCustomersInteractor(customerRepository: sessionContainer.customerRepository)
    }
    static private func getSetCustomerInCartUserCase(sessionContainer: SessionContainer) -> SetCustomerInCartUseCase {
        return SetCustomerInCartInteractor(
            cartRepository: sessionContainer.cartRepository
        )
    }
}
