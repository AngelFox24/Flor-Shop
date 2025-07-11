//
//  AddProductoToCartUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol AddProductoToCartUseCase {
    
    func execute(product: Product) throws
}

final class AddProductoToCartInteractor: AddProductoToCartUseCase {
    
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute(product: Product) throws {
        try self.cartRepository.addProductoToCarrito(product: product)
    }
}
