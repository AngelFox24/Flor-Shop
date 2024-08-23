//
//  PayClientDebtUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 28/03/24.
//

import Foundation

protocol PayClientDebtUseCase {
    
    func total(customer: Customer) -> Bool
}

final class PayClientDebtInteractor: PayClientDebtUseCase {
    
    private let customerRepository: CustomerRepository
    
    init(customerRepository: CustomerRepository) {
        self.customerRepository = customerRepository
    }
    
    func total(customer: Customer) -> Bool {
        do {
            return try customerRepository.payClientTotalDebt(customer: customer)
        } catch {
            return false
        }
    }
}

