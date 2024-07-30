//
//  SaveProductUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol SaveProductUseCase {
    func execute(product: Product) async throws
}
final class SaveProductInteractor: SaveProductUseCase {
    let productRepository: ProductRepository
    let imageRepository: ImageRepository
    init(
        productRepository: ProductRepository,
        imageRepository: ImageRepository
    ) {
        self.productRepository = productRepository
        self.imageRepository = imageRepository
    }
    func execute(product: Product) async throws {
        var productIn = product
        if let image = productIn.image {
            productIn.image = try self.imageRepository.save(image: image)
        }
        try await self.productRepository.save(product: productIn)
    }
}
