import Foundation

struct InviteEmployeeViewModelFactory {
    static func getInviteEmployeeViewModel(sessionContainer: SessionContainer) -> InviteEmployeeViewModel {
        return InviteEmployeeViewModel(
            getEmployeesUseCase: getEmployeeUseCase(sessionContainer: sessionContainer)
        )
    }
    static private func getEmployeeUseCase(sessionContainer: SessionContainer) -> GetEmployeesUseCase {
        return GetEmployeesUseCaseInteractor(employeeRepository: sessionContainer.employeeRepository)
    }
}
