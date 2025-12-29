import Foundation

struct SubsidiarySelectionViewModelFactory {
    static func getViewModel() -> SubsidiarySelectionViewModel {
        return SubsidiarySelectionViewModel(
        )
    }
    static private func getProductsUseCase(sessionContainer: SessionContainer) -> GetProductsUseCase {
        return GetProductInteractor(productRepository: sessionContainer.productRepository)
    }
    static private func getAddProductUseCase(sessionContainer: SessionContainer) -> AddProductoToCartUseCase {
        return AddProductoToCartInteractor(cartRepository: sessionContainer.cartRepository)
    }
}
