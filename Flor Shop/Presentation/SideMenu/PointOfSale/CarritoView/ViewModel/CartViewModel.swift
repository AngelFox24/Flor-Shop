//
//  CarritoCoreDataViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 1/05/23.
//
import CoreData
import Foundation

class CartViewModel: ObservableObject {
    @Published var cartCoreData: Car?
    @Published var customerInCar: Customer?
    @Published var paymentType: PaymentType = .cash
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
        self.cartCoreData = self.getCartUseCase.execute()
        print("When fecthing cart, totalInCart: \(self.cartCoreData?.total.cents ?? 0)")
    }
    func deleteCartDetail(cartDetail: CartDetail) async throws {
        try self.deleteCartDetailUseCase.execute(cartDetail: cartDetail)
    }
    func addProductoToCarrito(product: Product) async throws {
        try self.addProductoToCartUseCase.execute(product: product)
        await fetchCart()
    }
    func emptyCart() async throws {
        try self.emptyCartUseCase.execute()
        await fetchCart()
    }
    func changeProductAmount(productId: UUID, amount: Int) async throws {
        print("CartViewModel: changeProductAmount")
        try self.changeProductAmountInCartUseCase.execute(productId: productId, amount: amount)
    }
    func releaseResources() {
        self.cartCoreData = nil
        self.paymentType = .cash
    }
    func releaseCustomer() {
        self.customerInCar = nil
    }
    func lazyFetchCart() async {
        if cartCoreData == nil {
            await fetchCart()
        }
    }
}
