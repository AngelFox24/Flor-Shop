import Foundation
import FlorShopDTOs

protocol GetEmployeesUseCase {
    func execute(page: Int) async throws -> [Employee]
    func inviteEmployee(email: String, role: UserSubsidiaryRole) async throws
    func getEmployee(employeeCic: String) async throws -> Employee
    func isOwnProfile(employeeCic: String) -> Bool
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
    func getEmployee(employeeCic: String) async throws -> Employee {
        try await self.employeeRepository.getEmployee(employeeCic: employeeCic)
    }
    func isOwnProfile(employeeCic: String) -> Bool {
        self.employeeRepository.isOwnProfile(employeeCic: employeeCic)
    }
}
