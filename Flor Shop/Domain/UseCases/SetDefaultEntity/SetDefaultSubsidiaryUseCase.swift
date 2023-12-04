//
//  SetDefaultSubsidiaryUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation

protocol SetDefaultSubsidiaryUseCase {
    func execute(subsidiary: Subsidiary)
}

final class SetDefaultSubsidiaryInteractor: SetDefaultSubsidiaryUseCase {
    
    private let productReporsitory: ProductRepository
    private let employeeRepository: EmployeeRepository
    
    init(productReporsitory: ProductRepository, employeeRepository: EmployeeRepository) {
        self.productReporsitory = productReporsitory
        self.employeeRepository = employeeRepository
    }
   
    func execute(subsidiary: Subsidiary) {
        self.productReporsitory.setDefaultSubsidiary(subsidiary: subsidiary)
        self.employeeRepository.setDefaultSubsidiary(subsidiary: subsidiary)
    }
}
