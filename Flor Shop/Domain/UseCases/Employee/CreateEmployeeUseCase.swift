//
//  CreateEmployeeUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation

protocol CreateEmployeeUseCase {
    func execute(employee: Employee) async throws
}

final class CreateEmployeeInteractor: CreateEmployeeUseCase {
    private let synchronizerDBUseCase: SynchronizerDBUseCase
    private let employeeRepository: EmployeeRepository
    private let imageRepository: ImageRepository
    
    init(
        synchronizerDBUseCase: SynchronizerDBUseCase,
        employeeRepository: EmployeeRepository,
        imageRepository: ImageRepository
    ) {
        self.synchronizerDBUseCase = synchronizerDBUseCase
        self.employeeRepository = employeeRepository
        self.imageRepository = imageRepository
    }
    
    func execute(employee: Employee) async throws {
        var employeeIn = employee
        do {
            if let image = employeeIn.image {
                employeeIn.image = try await self.imageRepository.save(image: image)
            }
            try await self.employeeRepository.save(employee: employeeIn)
            try await self.synchronizerDBUseCase.sync()
        } catch {
            try await self.synchronizerDBUseCase.sync()
            throw error
        }
    }
}
