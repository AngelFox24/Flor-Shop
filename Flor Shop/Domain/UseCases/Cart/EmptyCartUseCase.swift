//
//  EmptyCartUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol EmptyCartUseCase {
    
    func execute()
}

final class EmptyCartInteractor: EmptyCartUseCase {
    
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute() {
        self.cartRepository.emptyCart()
        self.cartRepository.updateCartTotal()
    }
}
