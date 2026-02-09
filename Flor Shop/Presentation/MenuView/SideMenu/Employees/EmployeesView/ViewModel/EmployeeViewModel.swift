import Foundation

@Observable
final class EmployeeViewModel {
    var employeeList: [Employee] = []
    var searchText: String = ""
    private let getEmployeesUseCase: GetEmployeesUseCase
    init(getEmployeesUseCase: GetEmployeesUseCase) {
        self.getEmployeesUseCase = getEmployeesUseCase
    }
    // MARK: CRUD Core Data
    func fetchListEmployees() async throws {
        self.employeeList = try await self.getEmployeesUseCase.execute(page: 1)
    }
//    func lazyFetchList() {
//        if employeeList.isEmpty {
//            fetchListEmployees()
//        }
//    }
}
