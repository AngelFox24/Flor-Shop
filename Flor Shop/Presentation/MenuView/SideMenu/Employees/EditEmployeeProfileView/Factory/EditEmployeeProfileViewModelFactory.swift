import Foundation

struct EditEmployeeProfileViewModelFactory {
    static func getViewModel(sessionContainer: SessionContainer) -> EditEmployeeProfileViewModel {
        return EditEmployeeProfileViewModel(
            saveImageUseCase: saveImageUseCase(sessionContainer: sessionContainer),
            createEmployeeUseCase: getCreateEmployeeUseCase(sessionContainer: sessionContainer),
            getEmployeesUseCase: getEmployeeUseCase(sessionContainer: sessionContainer)
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
    static private func getEmployeeUseCase(sessionContainer: SessionContainer) -> GetEmployeesUseCase {
        return GetEmployeesUseCaseInteractor(employeeRepository: sessionContainer.employeeRepository)
    }
}
