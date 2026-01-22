import Foundation
import FlorShopDTOs

@Observable
class CartViewModel {
    var cartCoreData: Car?
    var customerInCar: Customer?
    var paymentType: PaymentType = .cash
    
    var paymentTypes: [PaymentType] {
        guard let customer = customerInCar else {
            return [.cash]
        }
        if customer.isCreditLimitActive || customer.isDateLimitActive {
            return PaymentType.allCases
        } else {
            return [.cash]
        }
    }
    private let getCartUseCase: GetCartUseCase
    private let deleteCartDetailUseCase: DeleteCartDetailUseCase
    private let addProductoToCartUseCase: AddProductoToCartUseCase
    private let emptyCartUseCase: EmptyCartUseCase
    private let changeProductAmountInCartUseCase: ChangeProductAmountInCartUseCase
    
    init(
        getCartUseCase: GetCartUseCase,
        deleteCartDetailUseCase: DeleteCartDetailUseCase,
        addProductoToCartUseCase: AddProductoToCartUseCase,
        emptyCartUseCase: EmptyCartUseCase,
        changeProductAmountInCartUseCase: ChangeProductAmountInCartUseCase
    ) {
        self.getCartUseCase = getCartUseCase
        self.deleteCartDetailUseCase = deleteCartDetailUseCase
        self.addProductoToCartUseCase = addProductoToCartUseCase
        self.emptyCartUseCase = emptyCartUseCase
        self.changeProductAmountInCartUseCase = changeProductAmountInCartUseCase
    }
    
    // MARK: CRUD Core Data
    @MainActor
    func fetchCart() async {
        self.cartCoreData = await self.getCartUseCase.execute()
        print("When fecthing cart, totalInCart: \(self.cartCoreData?.total.cents ?? 0)")
    }
    func deleteCartDetail(cartDetailId: UUID) async throws {
        try await self.deleteCartDetailUseCase.execute(cartDetailId: cartDetailId)
    }
    func addProductoToCarrito(product: Product) async throws {
        try await self.addProductoToCartUseCase.execute(product: product)
        await fetchCart()
    }
    func emptyCart() async throws {
        try await self.emptyCartUseCase.execute()
        await fetchCart()
    }
    func changeProductAmount(cartDetailId: UUID, productCic: String, amount: Int) async throws {
        print("CartViewModel: changeProductAmount")
        try await self.changeProductAmountInCartUseCase.execute(cartDetailId: cartDetailId, productCic: productCic, amount: amount)
    }
    func releaseResources() {
        self.cartCoreData = nil
        self.paymentType = .cash
    }
    func releaseCustomer() {
        self.customerInCar = nil
    }
}
