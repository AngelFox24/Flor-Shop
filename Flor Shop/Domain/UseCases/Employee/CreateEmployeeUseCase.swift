import Foundation

protocol CreateEmployeeUseCase {
    func execute(employee: Employee) async throws
}

final class CreateEmployeeInteractor: CreateEmployeeUseCase {
    private let employeeRepository: EmployeeRepository
    private let imageRepository: ImageRepository
    
    init(
        employeeRepository: EmployeeRepository,
        imageRepository: ImageRepository
    ) {
        self.employeeRepository = employeeRepository
        self.imageRepository = imageRepository
    }
    
    func execute(employee: Employee) async throws {
        try await self.employeeRepository.save(employee: employee)
    }
}
