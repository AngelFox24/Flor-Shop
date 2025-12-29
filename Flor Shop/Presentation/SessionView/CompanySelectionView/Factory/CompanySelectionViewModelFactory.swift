import Foundation

struct CompanySelectionViewModelFactory {
    static func getViewModel() -> CompanySelectionViewModel {
        return CompanySelectionViewModel(
        )
    }
    static private func getProductsUseCase(sessionContainer: SessionContainer) -> GetProductsUseCase {
        return GetProductInteractor(productRepository: sessionContainer.productRepository)
    }
    static private func getAddProductUseCase(sessionContainer: SessionContainer) -> AddProductoToCartUseCase {
        return AddProductoToCartInteractor(cartRepository: sessionContainer.cartRepository)
    }
}
