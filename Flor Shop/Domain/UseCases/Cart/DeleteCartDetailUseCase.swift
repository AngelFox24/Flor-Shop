//
//  DeleteCartDetailUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol DeleteCartDetailUseCase {
    
    func execute(cartDetail: CartDetail)
}

final class DeleteCartDetailInteractor: DeleteCartDetailUseCase {
    
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute(cartDetail: CartDetail) {
        self.cartRepository.deleteCartDetail(cartDetail: cartDetail)
        self.cartRepository.updateCartTotal()
    }
}
