import Foundation

struct CustomerViewModelFactory {
    static func getCustomerViewModelFactory(sessionContainer: SessionContainer) -> CustomerViewModel {
        return CustomerViewModel(
            getCustomersUseCase: getCustomersUseCase(sessionContainer: sessionContainer),
            setCustomerInCart: getSetCustomerInCartUserCase(sessionContainer: sessionContainer)
        )
    }
    static private func getCustomersUseCase(sessionContainer: SessionContainer) -> GetCustomersUseCase {
        return GetCustomersInteractor(
            customerRepository: sessionContainer.customerRepository
        )
    }
    static private func getSetCustomerInCartUserCase(sessionContainer: SessionContainer) -> SetCustomerInCartUseCase {
        return SetCustomerInCartInteractor(
            cartRepository: sessionContainer.cartRepository
        )
    }
}
