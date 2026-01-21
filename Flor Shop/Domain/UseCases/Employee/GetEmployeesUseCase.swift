import Foundation
import FlorShopDTOs

protocol GetEmployeesUseCase {
    func execute(page: Int) async throws -> [Employee]
    func inviteEmployee(email: String, role: UserSubsidiaryRole) async throws
}

final class GetEmployeesUseCaseInteractor: GetEmployeesUseCase {
    private let employeeRepository: EmployeeRepository
    
    init(employeeRepository: EmployeeRepository) {
        self.employeeRepository = employeeRepository
    }
    
    func execute(page: Int) async throws -> [Employee] {
        return try await self.employeeRepository.getEmployees()
    }
    
    func inviteEmployee(email: String, role: UserSubsidiaryRole) async throws {
        try await self.employeeRepository.invite(email: email, role: role)
    }
}
