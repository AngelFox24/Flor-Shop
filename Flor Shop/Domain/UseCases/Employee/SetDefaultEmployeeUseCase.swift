//
//  SetDefaultEmployeeUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation

protocol SetDefaultEmployeeUseCase {
    func execute(employee: Employee)
    func releaseResourses()
}

final class SetDefaultEmployeeInteractor: SetDefaultEmployeeUseCase {
    
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
   
    func execute(employee: Employee) {
        self.cartRepository.setDefaultEmployee(employee: employee)
        // Creamos un carrito si no existe
        self.cartRepository.createCart()
    }
    
    func releaseResourses() {
        self.cartRepository.releaseResourses()
    }
}
