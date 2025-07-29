import Foundation

protocol CreateEmployeeUseCase {
    func execute(employee: Employee) async throws
}

final class CreateEmployeeInteractor: CreateEmployeeUseCase {
//    private let synchronizerDBUseCase: SynchronizerDBUseCase
    private let employeeRepository: EmployeeRepository
    private let imageRepository: ImageRepository
    
    init(
//        synchronizerDBUseCase: SynchronizerDBUseCase,
        employeeRepository: EmployeeRepository,
        imageRepository: ImageRepository
    ) {
//        self.synchronizerDBUseCase = synchronizerDBUseCase
        self.employeeRepository = employeeRepository
        self.imageRepository = imageRepository
    }
    
    func execute(employee: Employee) async throws {
        do {
            try await self.employeeRepository.save(employee: employee)
//            try await self.synchronizerDBUseCase.sync()
        } catch {
//            try await self.synchronizerDBUseCase.sync()
            throw error
        }
    }
}
