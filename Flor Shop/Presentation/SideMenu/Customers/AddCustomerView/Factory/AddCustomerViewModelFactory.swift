import Foundation

struct AddCustomerViewModelFactory {
    static func getAddCustomerViewModel(sessionContainer: SessionContainer) -> AddCustomerViewModel {
        return AddCustomerViewModel(
            saveCustomerUseCase: getSaveCustomerUseCase(sessionContainer: sessionContainer),
            getImageUseCase: getImageUseCase(sessionContainer: sessionContainer)
        )
    }
    static private func getSaveCustomerUseCase(sessionContainer: SessionContainer) -> SaveCustomerUseCase {
        return SaveCustomerInteractor(
            customerRepository: sessionContainer.customerRepository,
            imageRepository: sessionContainer.imageRepository
        )
    }
    static private func getImageUseCase(sessionContainer: SessionContainer) -> GetImageUseCase {
        return GetImageInteractor(
            imageRepository: sessionContainer.imageRepository
        )
    }
}
