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
    
    private let saleRepository: SaleRepository
    
    init(saleRepository: SaleRepository) {
        self.saleRepository = saleRepository
    }
    
    func total(customer: Customer) -> Bool {
        do {
            return try saleRepository.payClientTotalDebt(customer: customer)
        } catch {
            return false
        }
    }
}

