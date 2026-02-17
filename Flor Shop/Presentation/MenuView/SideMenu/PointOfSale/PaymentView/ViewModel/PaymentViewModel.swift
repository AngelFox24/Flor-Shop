import Foundation
import FlorShopDTOs

@Observable
final class PaymentViewModel {
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
    var totalDisplay: String {
        guard let car = cartCoreData else {
            return "0.00"
        }
        switch paymentType {
        case .cash:
            return car.totalRounded.solesString
        case .loan:
            return car.total.solesString
        }
    }
    private let getCartUseCase: GetCartUseCase
    private let emptyCartUseCase: EmptyCartUseCase
    private let registerSaleUseCase: RegisterSaleUseCase
    private let getCustomersUseCase: GetCustomersUseCase
    private let setCustomerInCartUseCase: SetCustomerInCartUseCase
    
    init(
        registerSaleUseCase: RegisterSaleUseCase,
        getCartUseCase: GetCartUseCase,
        emptyCartUseCase: EmptyCartUseCase,
        getCustomersUseCase: GetCustomersUseCase,
        setCustomerInCartUseCase: SetCustomerInCartUseCase
    ) {
        self.registerSaleUseCase = registerSaleUseCase
        self.getCartUseCase = getCartUseCase
        self.emptyCartUseCase = emptyCartUseCase
        self.getCustomersUseCase = getCustomersUseCase
        self.setCustomerInCartUseCase = setCustomerInCartUseCase
    }
    
    @MainActor
    func fetchCart() async {
        self.cartCoreData = await self.getCartUseCase.execute()
        await fechtCustomer()
    }
    func fechtCustomer() async {
        let customerInCar: Customer?
        if let customerCic = cartCoreData?.customerCic {
            customerInCar = await self.getCustomersUseCase.getCustomer(customerCic: customerCic)
        } else {
            customerInCar = nil
        }
        await MainActor.run {
            self.customerInCar = customerInCar
        }
    }
    func emptyCart() async throws {
        try await self.emptyCartUseCase.execute()
        await fetchCart()
    }
    func registerSale() async throws {
        guard let cart = cartCoreData else { return }
        try await self.registerSaleUseCase.execute(cart: cart, paymentType: paymentType, customerCic: customerInCar?.customerCic)
    }
    func unlinkClient() {
        Task {
            guard let _ = customerInCar else { return }
            await self.setCustomerInCartUseCase.execute(customerCic: nil)
            await fetchCart()
        }
    }
}
