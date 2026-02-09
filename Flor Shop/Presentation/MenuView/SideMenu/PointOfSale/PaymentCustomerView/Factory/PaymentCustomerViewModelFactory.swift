import Foundation

struct PaymentCustomerViewModelFactory {
    static func getPaymentViewModel(sessionContainer: SessionContainer) -> PaymentCustomerViewModel {
        return PaymentCustomerViewModel(
            getCustomersUseCase: getCustomersUseCase(sessionContainer: sessionContainer),
            payClientDebtUseCase: getPayClientDebtUseCase(sessionContainer: sessionContainer)
        )
    }
    static private func getCustomersUseCase(sessionContainer: SessionContainer) -> GetCustomersUseCase {
        return GetCustomersInteractor(customerRepository: sessionContainer.customerRepository)
    }
    static private func getPayClientDebtUseCase(sessionContainer: SessionContainer) -> PayClientDebtUseCase {
        return PayClientDebtInteractor(customerRepository: sessionContainer.customerRepository)
    }
}
