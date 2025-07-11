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
//    private let synchronizerDBUseCase: SynchronizerDBUseCase
    private let customerRepository: CustomerRepository
    
    init(
//        synchronizerDBUseCase: SynchronizerDBUseCase,
        customerRepository: CustomerRepository
    ) {
//        self.synchronizerDBUseCase = synchronizerDBUseCase
        self.customerRepository = customerRepository
    }
    
    func total(customer: Customer) async throws -> Bool {
        do {
            let result = try await customerRepository.payClientTotalDebt(customer: customer)
//            try await self.synchronizerDBUseCase.sync()
            return result
        } catch {
//            try await self.synchronizerDBUseCase.sync()
            throw error
        }
    }
}

