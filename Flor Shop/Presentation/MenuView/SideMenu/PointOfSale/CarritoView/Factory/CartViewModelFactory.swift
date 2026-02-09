import Foundation

struct CartViewModelFactory {
    static func getCartViewModel(sessionContainer: SessionContainer) -> CartViewModel {
        return CartViewModel(
            getCartUseCase: getCartUseCase(sessionContainer: sessionContainer),
            deleteCartDetailUseCase: getDeleteCartDetailUseCase(sessionContainer: sessionContainer),
            addProductoToCartUseCase: getAddProductoToCartUseCase(sessionContainer: sessionContainer),
            emptyCartUseCase: getEmptyCartUseCase(sessionContainer: sessionContainer),
            changeProductAmountInCartUseCase: getChangeProductAmountInCartUseCase(sessionContainer: sessionContainer),
            getCustomersUseCase: getCustomersUseCase(sessionContainer: sessionContainer),
            setCustomerInCartUseCase: getSetCustomerInCartUserCase(sessionContainer: sessionContainer)
        )
    }
    static private func getCartUseCase(sessionContainer: SessionContainer) -> GetCartUseCase {
        return GetCartInteractor(cartRepository: sessionContainer.cartRepository)
    }
    static private func getDeleteCartDetailUseCase(sessionContainer: SessionContainer) -> DeleteCartDetailUseCase {
        return DeleteCartDetailInteractor(cartRepository: sessionContainer.cartRepository)
    }
    static private func getAddProductoToCartUseCase(sessionContainer: SessionContainer) -> AddProductoToCartUseCase {
        return AddProductoToCartInteractor(cartRepository: sessionContainer.cartRepository)
    }
    static private func getEmptyCartUseCase(sessionContainer: SessionContainer) -> EmptyCartUseCase {
        return EmptyCartInteractor(cartRepository: sessionContainer.cartRepository)
    }
    static private func getChangeProductAmountInCartUseCase(sessionContainer: SessionContainer) -> ChangeProductAmountInCartUseCase {
        return ChangeProductAmountInCartInteractor(cartRepository: sessionContainer.cartRepository)
    }
    static private func getCustomersUseCase(sessionContainer: SessionContainer) -> GetCustomersUseCase {
        return GetCustomersInteractor(customerRepository: sessionContainer.customerRepository)
    }
    static private func getSetCustomerInCartUserCase(sessionContainer: SessionContainer) -> SetCustomerInCartUseCase {
        return SetCustomerInCartInteractor(
            cartRepository: sessionContainer.cartRepository
        )
    }
}
