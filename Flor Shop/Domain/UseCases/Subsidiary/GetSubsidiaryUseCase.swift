//
//  GetSubsidiaryUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation

protocol GetSubsidiaryUseCase {
    func execute(employee: Employee) -> Subsidiary?
}

final class GetSubsidiaryInteractor: GetSubsidiaryUseCase {
    
    private let employeeRepository: EmployeeRepository
    
    init(employeeRepository: EmployeeRepository) {
        self.employeeRepository = employeeRepository
    }
   
    func execute(employee: Employee) -> Subsidiary? {
        return self.employeeRepository.getSubsidiary(employee: employee)
    }
}
