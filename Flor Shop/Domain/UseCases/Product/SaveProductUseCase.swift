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
//    private let synchronizerDBUseCase: SynchronizerDBUseCase
    private let productRepository: ProductRepository
    private let imageRepository: ImageRepository
    init(
//        synchronizerDBUseCase: SynchronizerDBUseCase,
        productRepository: ProductRepository,
        imageRepository: ImageRepository
    ) {
//        self.synchronizerDBUseCase = synchronizerDBUseCase
        self.productRepository = productRepository
        self.imageRepository = imageRepository
    }
    func execute(product: Product) async throws {
        do {
            try await self.productRepository.save(product: product)
//            try await self.synchronizerDBUseCase.sync()
        } catch {
//            try await self.synchronizerDBUseCase.sync()
            throw error
        }
    }
}
