//
//  SaveProductUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol SaveProductUseCase {
    func execute(product: Product) async throws -> String
}
final class SaveProductInteractor: SaveProductUseCase {
    let productRepository: ProductRepository
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }
    func execute(product: Product) async throws -> String {
        //return self.subsidiaryRepository.addSubsidiary(subsidiary: subsidiary)
        try await self.productRepository.saveProduct(product: product)
        return "success"
    }
}
