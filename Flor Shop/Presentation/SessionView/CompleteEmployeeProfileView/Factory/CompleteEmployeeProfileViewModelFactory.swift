import Foundation

struct CompleteEmployeeProfileViewModelFactory {
    static func getViewModel(sessionContainer: SessionContainer) -> CompleteEmployeeProfileViewModel {
        return CompleteEmployeeProfileViewModel(
            saveImageUseCase: saveImageUseCase(sessionContainer: sessionContainer),
            createEmployeeUseCase: getCreateEmployeeUseCase(sessionContainer: sessionContainer),
            emptyCartUseCase: getEmptyCartUseCase(sessionContainer: sessionContainer)
        )
    }
    static private func getCreateEmployeeUseCase(sessionContainer: SessionContainer) -> CreateEmployeeUseCase {
        return CreateEmployeeInteractor(employeeRepository: sessionContainer.employeeRepository)
    }
    static private func saveImageUseCase(sessionContainer: SessionContainer) -> SaveImageUseCase {
        return SaveImageInteractor(
            imageRepository: sessionContainer.imageRepository
        )
    }
    static private func getEmptyCartUseCase(sessionContainer: SessionContainer) -> EmptyCartUseCase {
        return EmptyCartInteractor(cartRepository: sessionContainer.cartRepository)
    }
}
