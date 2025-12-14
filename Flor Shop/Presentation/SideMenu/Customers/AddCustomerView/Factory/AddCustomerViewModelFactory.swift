import Foundation

struct AddCustomerViewModelFactory {
    static func getAddCustomerViewModel(sessionContainer: SessionContainer) -> AddCustomerViewModel {
        return AddCustomerViewModel(
            saveCustomerUseCase: getSaveCustomerUseCase(sessionContainer: sessionContainer),
            saveImageUseCase: saveImageUseCase(sessionContainer: sessionContainer)
        )
    }
    static private func getSaveCustomerUseCase(sessionContainer: SessionContainer) -> SaveCustomerUseCase {
        return SaveCustomerInteractor(
            customerRepository: sessionContainer.customerRepository,
            imageRepository: sessionContainer.imageRepository
        )
    }
    static private func saveImageUseCase(sessionContainer: SessionContainer) -> SaveImageUseCase {
        return SaveImageInteractor(
            imageRepository: sessionContainer.imageRepository
        )
    }
}
