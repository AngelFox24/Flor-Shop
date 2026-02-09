import Foundation
import FlorShopDTOs

@Observable
final class CartViewModel {
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
    private let getCustomersUseCase: GetCustomersUseCase
    private let setCustomerInCartUseCase: SetCustomerInCartUseCase
    
    init(
        getCartUseCase: GetCartUseCase,
        deleteCartDetailUseCase: DeleteCartDetailUseCase,
        addProductoToCartUseCase: AddProductoToCartUseCase,
        emptyCartUseCase: EmptyCartUseCase,
        changeProductAmountInCartUseCase: ChangeProductAmountInCartUseCase,
        getCustomersUseCase: GetCustomersUseCase,
        setCustomerInCartUseCase: SetCustomerInCartUseCase
    ) {
        self.getCartUseCase = getCartUseCase
        self.deleteCartDetailUseCase = deleteCartDetailUseCase
        self.addProductoToCartUseCase = addProductoToCartUseCase
        self.emptyCartUseCase = emptyCartUseCase
        self.changeProductAmountInCartUseCase = changeProductAmountInCartUseCase
        self.getCustomersUseCase = getCustomersUseCase
        self.setCustomerInCartUseCase = setCustomerInCartUseCase
    }
    
    // MARK: CRUD Core Data
    @MainActor
    func fetchCart() async {
        self.cartCoreData = await self.getCartUseCase.execute()
        print("When fecthing cart, totalInCart: \(self.cartCoreData?.total.cents ?? 0)")
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
    func stepProductAmount(cartDetailId: UUID, type: TypeOfVariation) async throws {
        try await self.changeProductAmountInCartUseCase.stepProductAmount(cartDetailId: cartDetailId, type: type)
    }
    func deleteCartDetail(cartDetailId: UUID) async throws {
        try await self.deleteCartDetailUseCase.execute(cartDetailId: cartDetailId)
    }
    func addProductInCart(barcode: String) async throws {
        try await self.addProductoToCartUseCase.execute(barcode: barcode)
    }
    func emptyCart() async throws {
        try await self.emptyCartUseCase.execute()
        await fetchCart()
    }
    func changeProductAmount(cartDetailId: UUID, amount: Int) async throws {
        print("CartViewModel: changeProductAmount")
        try await self.changeProductAmountInCartUseCase.execute(cartDetailId: cartDetailId, amount: amount)
    }
    func unlinkClient() {
        Task {
            guard let _ = customerInCar else { return }
            await self.setCustomerInCartUseCase.execute(customerCic: nil)
            await fetchCart()
        }
    }
    func releaseResources() {
        self.cartCoreData = nil
        self.paymentType = .cash
    }
    func releaseCustomer() {
        self.customerInCar = nil
    }
}
