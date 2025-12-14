import Foundation

protocol SaveProductUseCase {
    func execute(product: Product) async throws
}
final class SaveProductInteractor: SaveProductUseCase {
    private let productRepository: ProductRepository
    private let imageRepository: ImageRepository
    init(
        productRepository: ProductRepository,
        imageRepository: ImageRepository
    ) {
        self.productRepository = productRepository
        self.imageRepository = imageRepository
    }
    func execute(product: Product) async throws {
        try await self.productRepository.save(product: product)
    }
}
