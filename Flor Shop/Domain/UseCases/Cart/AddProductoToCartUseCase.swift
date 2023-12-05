//
//  AddProductoToCartUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol AddProductoToCartUseCase {
    
    func execute(product: Product) -> Bool
}

final class AddProductoToCartInteractor: AddProductoToCartUseCase {
    
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute(product: Product) -> Bool {
        let result = self.cartRepository.addProductoToCarrito(product: product)
        self.cartRepository.updateCartTotal()
        return result
    }
}
