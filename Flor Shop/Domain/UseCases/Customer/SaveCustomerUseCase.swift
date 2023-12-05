//
//  SaveCustomerUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol SaveCustomerUseCase {
    
    func execute(customer: Customer) -> String
}

final class SaveCustomerInteractor: SaveCustomerUseCase {
    
    private let customerRepository: CustomerRepository
    
    init(customerRepository: CustomerRepository) {
        self.customerRepository = customerRepository
    }
    
    func execute(customer: Customer) -> String {
        return self.customerRepository.addCustomer(customer: customer)
    }
}
