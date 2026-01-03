import Foundation

protocol CreateEmployeeUseCase {
    func execute(employee: Employee) async throws
}

final class CreateEmployeeInteractor: CreateEmployeeUseCase {
    private let employeeRepository: EmployeeRepository
    
    init(
        employeeRepository: EmployeeRepository
    ) {
        self.employeeRepository = employeeRepository
    }
    
    func execute(employee: Employee) async throws {
        try await self.employeeRepository.save(employee: employee)
    }
}
