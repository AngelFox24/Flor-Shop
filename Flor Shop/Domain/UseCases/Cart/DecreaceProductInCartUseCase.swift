//
//  DecreaceProductInCartUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol DecreaceProductInCartUseCase {
    
    func execute(cartDetail: CartDetail)
}

final class DecreaceProductInCartInteractor: DecreaceProductInCartUseCase {
    
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute(cartDetail: CartDetail) {
        self.cartRepository.decreceProductAmount(cartDetail: cartDetail)
        self.cartRepository.updateCartTotal()
    }
}
