//
//  GetEmployeesUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol GetEmployeesUseCase {
    
    func execute(page: Int) -> [Employee]
}

final class GetEmployeesUseCaseInteractor: GetEmployeesUseCase {
    
    private let employeeRepository: EmployeeRepository
    
    init(employeeRepository: EmployeeRepository) {
        self.employeeRepository = employeeRepository
    }
    
    func execute(page: Int) -> [Employee] {
        return self.employeeRepository.getEmployees()
    }
}
