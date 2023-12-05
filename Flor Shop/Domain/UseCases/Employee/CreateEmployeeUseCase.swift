//
//  CreateEmployeeUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation

protocol CreateEmployeeUseCase {
    func execute(employee: Employee) -> Bool
}

final class CreateEmployeeInteractor: CreateEmployeeUseCase {
    
    private let employeeRepository: EmployeeRepository
    
    init(employeeRepository: EmployeeRepository) {
        self.employeeRepository = employeeRepository
    }
    
    func execute(employee: Employee) -> Bool {
        return self.employeeRepository.addEmployee(employee: employee)
    }
}
