//
//  GetCartUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol GetCartUseCase {
    
    func execute() -> Car?
}

final class GetCartInteractor: GetCartUseCase {
    
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute() -> Car? {
        do {
            return try self.cartRepository.getCart()
        } catch {
            return nil
        }
    }
}
