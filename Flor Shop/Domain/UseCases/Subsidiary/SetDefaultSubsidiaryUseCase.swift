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
    private let saleRepository: SaleRepository
    
    init(productReporsitory: ProductRepository, employeeRepository: EmployeeRepository, saleRepository: SaleRepository) {
        self.productReporsitory = productReporsitory
        self.employeeRepository = employeeRepository
        self.saleRepository = saleRepository
    }
   
    func execute(subsidiary: Subsidiary) {
        self.productReporsitory.setDefaultSubsidiary(subsidiary: subsidiary)
        self.employeeRepository.setDefaultSubsidiary(subsidiary: subsidiary)
        self.saleRepository.setDefaultSubsidiary(subsidiary: subsidiary)
    }
}
