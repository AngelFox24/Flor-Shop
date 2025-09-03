import Foundation

struct EmployeeViewModelFactory {
    static func getEmployeeViewModel(sessionContainer: SessionContainer) -> EmployeeViewModel {
        return EmployeeViewModel(
            getEmployeesUseCase: getEmployeeUseCase(sessionContainer: sessionContainer)
        )
    }
    static private func getEmployeeUseCase(sessionContainer: SessionContainer) -> GetEmployeesUseCase {
        return GetEmployeesUseCaseInteractor(employeeRepository: sessionContainer.employeeRepository)
    }
}
