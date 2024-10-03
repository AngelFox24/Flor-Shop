//
//  PayClientDebtUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 28/03/24.
//

import Foundation

protocol PayClientDebtUseCase {
    func total(customer: Customer) async throws -> Bool
}

final class PayClientDebtInteractor: PayClientDebtUseCase {
    
    private let customerRepository: CustomerRepository
    
    init(customerRepository: CustomerRepository) {
        self.customerRepository = customerRepository
    }
    
    func total(customer: Customer) async throws -> Bool {
        return try await customerRepository.payClientTotalDebt(customer: customer)
    }
}

