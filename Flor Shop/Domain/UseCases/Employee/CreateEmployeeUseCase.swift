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
        var employeeIn = employee
        if let image = employeeIn.image {
            employeeIn.image = try self.imageRepository.save(image: image)
        }
        self.employeeRepository.save(employee: employeeIn)
    }
}
