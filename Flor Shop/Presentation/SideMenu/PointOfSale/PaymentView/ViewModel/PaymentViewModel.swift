import Foundation

@Observable
class PaymentViewModel {
    var cartCoreData: Car?
    var customerInCar: Customer?
    var paymentType: PaymentType = .cash
    
    var paymentTypes: [PaymentType] {
        guard let customer = customerInCar else {
            return [.cash]
        }
        if customer.isCreditLimitActive || customer.isDateLimitActive {
            return PaymentType.allValues
        } else {
            return [.cash]
        }
    }
    private let getCartUseCase: GetCartUseCase
    private let emptyCartUseCase: EmptyCartUseCase
    private let registerSaleUseCase: RegisterSaleUseCase
    
    init(
        registerSaleUseCase: RegisterSaleUseCase,
        getCartUseCase: GetCartUseCase,
        emptyCartUseCase: EmptyCartUseCase
    ) {
        self.registerSaleUseCase = registerSaleUseCase
        self.getCartUseCase = getCartUseCase
        self.emptyCartUseCase = emptyCartUseCase
    }
    
    @MainActor
    func fetchCart() async {
        self.cartCoreData = self.getCartUseCase.execute()
    }
    func emptyCart() async throws {
        try self.emptyCartUseCase.execute()
        await fetchCart()
    }
    func registerSale() async throws {
        guard let cart = cartCoreData else { return }
        try await self.registerSaleUseCase.execute(cart: cart, paymentType: paymentType, customerId: customerInCar?.customerId)
    }
}
