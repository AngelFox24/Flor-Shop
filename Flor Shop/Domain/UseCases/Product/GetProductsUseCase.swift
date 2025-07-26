//
//  GetProductsUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation

protocol GetProductsUseCase {
    func getLastToken() -> Int64
    func updateProducts(products: [Product]) -> [Product]
    func execute(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int) -> [Product]
}

final class GetProductInteractor: GetProductsUseCase {
    private let productRepository: ProductRepository
    
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }
    
    func getLastToken() -> Int64 {
        return self.productRepository.getLastToken()
    }
    
    func updateProducts(products: [Product]) -> [Product] {
        return self.productRepository.updateProducts(products: products)
    }
    
    func execute(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int) -> [Product] {
        guard page >= 1 else { return [] }
        return self.productRepository.getProducts(seachText: seachText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page, pageSize: 15)
    }
}
