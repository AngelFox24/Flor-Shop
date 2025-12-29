import Foundation

@Observable
class EmployeeViewModel {
    var employeeList: [Employee] = []
    var searchText: String = ""
    private let getEmployeesUseCase: GetEmployeesUseCase
    init(getEmployeesUseCase: GetEmployeesUseCase) {
        self.getEmployeesUseCase = getEmployeesUseCase
        fetchListEmployees()
    }
    // MARK: CRUD Core Data
    func fetchListEmployees() {
        self.employeeList = self.getEmployeesUseCase.execute(page: 1)
    }
    func lazyFetchList() {
        if employeeList.isEmpty {
            fetchListEmployees()
        }
    }
}
