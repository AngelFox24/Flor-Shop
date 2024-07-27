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
    @Published var error: String = ""
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
    func fetchCart() {
        self.cartCoreData = self.getCartUseCase.execute()
    }
    func deleteCartDetail(cartDetail: CartDetail) async {
        do {
            try self.deleteCartDetailUseCase.execute(cartDetail: cartDetail)
        } catch {
            await MainActor.run {
                self.error = "Error Inesperado"
            }
        }
        fetchCart()
    }
    func addProductoToCarrito(product: Product) async throws {
        try self.addProductoToCartUseCase.execute(product: product)
        fetchCart()
    }
    func emptyCart() async {
        do {
            try self.emptyCartUseCase.execute()
        } catch {
            await MainActor.run {
                self.error = "Error Inesperado"
            }
        }
        fetchCart()
    }
    func changeProductAmount(cartDetail: CartDetail) async {
        do {
            try self.changeProductAmountInCartUseCase.execute(cartDetail: cartDetail)
        } catch {
            await MainActor.run {
                self.error = "Error Inesperado"
            }
        }
        fetchCart()
    }
    func releaseResources() {
        self.cartCoreData = nil
        self.paymentType = .cash
    }
    func releaseCustomer() {
        self.customerInCar = nil
    }
    func lazyFetchCart() {
        if cartCoreData == nil {
            fetchCart()
        }
    }
}
