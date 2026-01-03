import Foundation
import FlorShopDTOs

protocol GetEmployeesUseCase {
    func execute(page: Int) -> [Employee]
    func inviteEmployee(email: String, role: UserSubsidiaryRole) async throws
}

final class GetEmployeesUseCaseInteractor: GetEmployeesUseCase {
    private let employeeRepository: EmployeeRepository
    
    init(employeeRepository: EmployeeRepository) {
        self.employeeRepository = employeeRepository
    }
    
    func execute(page: Int) -> [Employee] {
        return self.employeeRepository.getEmployees()
    }
    
    func inviteEmployee(email: String, role: UserSubsidiaryRole) async throws {
        try await self.employeeRepository.invite(email: email, role: role)
    }
}
