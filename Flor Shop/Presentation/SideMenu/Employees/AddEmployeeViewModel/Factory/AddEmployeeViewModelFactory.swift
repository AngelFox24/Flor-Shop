import Foundation

struct AddEmployeeViewModelFactory {
    static func getAddEmployeeViewModel(sessionContainer: SessionContainer) -> AddEmployeeViewModel {
        return AddEmployeeViewModel(
            getEmployeesUseCase: getEmployeeUseCase(sessionContainer: sessionContainer)
        )
    }
    static private func getEmployeeUseCase(sessionContainer: SessionContainer) -> GetEmployeesUseCase {
        return GetEmployeesUseCaseInteractor(employeeRepository: sessionContainer.employeeRepository)
    }
}
