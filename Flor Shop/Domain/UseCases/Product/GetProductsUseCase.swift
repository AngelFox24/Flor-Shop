import Foundation

protocol GetProductsUseCase {
    func updateProducts(products: [Product]) -> [Product]
    func execute(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int) async throws -> [Product]
    func getProduct(productCic: String) async throws -> Product
}

final class GetProductInteractor: GetProductsUseCase {
    private let productRepository: ProductRepository
    
    init(
        productRepository: ProductRepository
    ) {
        self.productRepository = productRepository
    }
    func updateProducts(products: [Product]) -> [Product] {
        return self.productRepository.updateProducts(products: products)
    }
    func execute(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int) async throws -> [Product] {
        guard page >= 1 else { return [] }
        return try await self.productRepository.getProducts(seachText: seachText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page, pageSize: 15)
    }
    func getProduct(productCic: String) async throws -> Product {
        return try await self.productRepository.getProduct(productCic: productCic)
    }
}
