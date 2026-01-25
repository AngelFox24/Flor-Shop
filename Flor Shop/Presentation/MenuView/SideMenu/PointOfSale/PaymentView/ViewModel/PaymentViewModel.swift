import Foundation
import FlorShopDTOs

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
            return PaymentType.allCases
        } else {
            return [.cash]
        }
    }
    private let getCartUseCase: GetCartUseCase
    private let emptyCartUseCase: EmptyCartUseCase
    private let registerSaleUseCase: RegisterSaleUseCase
    private let getCustomersUseCase: GetCustomersUseCase
    
    init(
        registerSaleUseCase: RegisterSaleUseCase,
        getCartUseCase: GetCartUseCase,
        emptyCartUseCase: EmptyCartUseCase,
        getCustomersUseCase: GetCustomersUseCase
    ) {
        self.registerSaleUseCase = registerSaleUseCase
        self.getCartUseCase = getCartUseCase
        self.emptyCartUseCase = emptyCartUseCase
        self.getCustomersUseCase = getCustomersUseCase
    }
    
    @MainActor
    func fetchCart() async {
        self.cartCoreData = await self.getCartUseCase.execute()
        guard let customerCic = cartCoreData?.customerCic else {
            return
        }
        let customer = await self.getCustomersUseCase.getCustomer(customerCic: customerCic)//TODO: Refactor, debe llamarse desde un hilo no principal
        self.customerInCar = customer
    }
    func emptyCart() async throws {
        try await self.emptyCartUseCase.execute()
        await fetchCart()
    }
    func registerSale() async throws {
        guard let cart = cartCoreData else { return }
        try await self.registerSaleUseCase.execute(cart: cart, paymentType: paymentType, customerCic: customerInCar?.customerCic)
    }
}
