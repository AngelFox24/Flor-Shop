import Foundation

struct CustomerHistoryViewModelFactory {
    static func getCustomerHistoryViewModel(sessionContainer: SessionContainer) -> CustomerHistoryViewModel {
        return CustomerHistoryViewModel(
            getCustomerSalesUseCase: getGetCustomerSalesUseCase(sessionContainer: sessionContainer),
            getCustomersUseCase: getGetCustomersUseCase(sessionContainer: sessionContainer),
            payClientDebtUseCase: getPayClientDebtUseCase(sessionContainer: sessionContainer)
        )
    }
    static private func getGetCustomerSalesUseCase(sessionContainer: SessionContainer) -> GetCustomerSalesUseCase {
        return GetCustomerSalesInteractor(
            customerRepository: sessionContainer.customerRepository
        )
    }
    static private func getGetCustomersUseCase(sessionContainer: SessionContainer) -> GetCustomersUseCase {
        return GetCustomersInteractor(
            customerRepository: sessionContainer.customerRepository
        )
    }
    static private func getPayClientDebtUseCase(sessionContainer: SessionContainer) -> PayClientDebtUseCase {
        return PayClientDebtInteractor(
            customerRepository: sessionContainer.customerRepository
        )
    }
}
