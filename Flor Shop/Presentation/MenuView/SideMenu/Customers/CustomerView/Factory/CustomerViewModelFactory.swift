import Foundation

struct CustomerViewModelFactory {
    static func getCustomerViewModelFactory(sessionContainer: SessionContainer) -> CustomerViewModel {
        return CustomerViewModel(
            getCustomersUseCase: getCustomersUseCase(sessionContainer: sessionContainer)
        )
    }
    static private func getCustomersUseCase(sessionContainer: SessionContainer) -> GetCustomersUseCase {
        return GetCustomersInteractor(
            customerRepository: sessionContainer.customerRepository
        )
    }
}
