import Foundation

struct ProductViewModelFactory {
    static func getProductViewModel(sessionContainer: SessionContainer) -> ProductViewModel {
        return ProductViewModel(
            getProductsUseCase: getProductsUseCase(sessionContainer: sessionContainer),
            addProductoToCartUseCase: getAddProductUseCase(sessionContainer: sessionContainer)
        )
    }
    static private func getProductsUseCase(sessionContainer: SessionContainer) -> GetProductsUseCase {
        return GetProductInteractor(productRepository: sessionContainer.productRepository)
    }
    static private func getAddProductUseCase(sessionContainer: SessionContainer) -> AddProductoToCartUseCase {
        return AddProductoToCartInteractor(cartRepository: sessionContainer.cartRepository)
    }
}
