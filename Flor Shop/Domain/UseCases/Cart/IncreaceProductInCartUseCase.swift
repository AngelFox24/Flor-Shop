//
//  IncreaceProductInCartUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol IncreaceProductInCartUseCase {
    
    func execute(cartDetail: CartDetail)
}

final class IncreaceProductInCartInteractor: IncreaceProductInCartUseCase {
    
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute(cartDetail: CartDetail) {
        self.cartRepository.increaceProductAmount(cartDetail: cartDetail)
        self.cartRepository.updateCartTotal()
    }
}
