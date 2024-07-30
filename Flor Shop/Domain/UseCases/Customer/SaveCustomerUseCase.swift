//
//  SaveCustomerUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol SaveCustomerUseCase {
    
    func execute(customer: Customer) async throws
}

final class SaveCustomerInteractor: SaveCustomerUseCase {
    
    private let customerRepository: CustomerRepository
    private let imageRepository: ImageRepository
    
    init(
        customerRepository: CustomerRepository,
        imageRepository: ImageRepository
    ) {
        self.customerRepository = customerRepository
        self.imageRepository = imageRepository
    }
    
    func execute(customer: Customer) async throws {
        var customerIn = customer
        if let image = customerIn.image {
            customerIn.image = try self.imageRepository.save(image: image)
        }
        return self.customerRepository.save(customer: customerIn)
    }
}
