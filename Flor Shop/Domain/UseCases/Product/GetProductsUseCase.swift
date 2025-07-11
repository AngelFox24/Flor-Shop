//
//  GetProductsUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation

protocol GetProductsUseCase {
    func execute(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int) -> [Product]
}

final class GetProductInteractor: GetProductsUseCase {
    private let productRepository: ProductRepository
    
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }
    
    func execute(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int) -> [Product] {
        guard page >= 1 else { return [] }
        return self.productRepository.getProducts(seachText: seachText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page, pageSize: 15)
    }
}
