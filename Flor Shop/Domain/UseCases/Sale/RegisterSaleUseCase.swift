//
//  RegisterSaleUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol RegisterSaleUseCase {
    
    func execute(cart: Car?, customer: Customer?, paymentType: PaymentType) async throws
}

final class RegisterSaleInteractor: RegisterSaleUseCase {
    
    private let saleRepository: SaleRepository
    
    init(saleRepository: SaleRepository) {
        self.saleRepository = saleRepository
    }
    
    func execute(cart: Car?, customer: Customer?, paymentType: PaymentType) async throws {
        try await self.saleRepository.registerSale(cart: cart, customer: customer, paymentType: paymentType)
    }
}
