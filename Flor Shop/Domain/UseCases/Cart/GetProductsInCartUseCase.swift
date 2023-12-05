//
//  GetProductsInCartUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol GetProductsInCartUseCase {
    
    func execute(page: Int) -> [CartDetail]
}

final class GetProductsInCartInteractor: GetProductsInCartUseCase {
    
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute(page: Int) -> [CartDetail] {
        guard page >= 1 else { return [] }
        return self.cartRepository.getListProductInCart()
    }
}
