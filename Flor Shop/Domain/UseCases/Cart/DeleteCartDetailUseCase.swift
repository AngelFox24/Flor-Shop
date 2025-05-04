//
//  DeleteCartDetailUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol DeleteCartDetailUseCase {
    
    func execute(cartDetail: CartDetail) throws
}

final class DeleteCartDetailInteractor: DeleteCartDetailUseCase {
    
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute(cartDetail: CartDetail) throws {
        try self.cartRepository.deleteCartDetail(cartDetail: cartDetail)
    }
}
