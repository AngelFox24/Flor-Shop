//
//  RegisterSaleUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol RegisterSaleUseCase {
    func execute(cart: Car, paymentType: PaymentType, customerId: UUID?) async throws
}

final class RegisterSaleInteractor: RegisterSaleUseCase {
    private let synchronizerDBUseCase: SynchronizerDBUseCase
    private let saleRepository: SaleRepository
    
    init(
        synchronizerDBUseCase: SynchronizerDBUseCase,
        saleRepository: SaleRepository
    ) {
        self.synchronizerDBUseCase = synchronizerDBUseCase
        self.saleRepository = saleRepository
    }
    
    func execute(cart: Car, paymentType: PaymentType, customerId: UUID?) async throws {
        do {
            try await self.saleRepository.registerSale(cart: cart, paymentType: paymentType, customerId: customerId)
            try await self.synchronizerDBUseCase.sync()
        } catch {
            try await self.synchronizerDBUseCase.sync()
            throw error
        }
    }
}
