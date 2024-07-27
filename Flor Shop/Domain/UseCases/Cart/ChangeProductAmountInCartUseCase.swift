//
//  DecreaceProductInCartUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol ChangeProductAmountInCartUseCase {
    func execute(cartDetail: CartDetail) throws
}

final class ChangeProductAmountInCartInteractor: ChangeProductAmountInCartUseCase {
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute(cartDetail: CartDetail) throws {
        try self.cartRepository.changeProductAmountInCartDetail(cartDetail: cartDetail)
        try self.cartRepository.updateCartTotal()
    }
}
