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
    @Published var cartDetailCoreData: [CartDetail] = []
    @Published var customerInCar: Customer?
    @Published var paymentType: PaymentType = .cash
    private let getProductsInCartUseCase: GetProductsInCartUseCase
    private let getCartUseCase: GetCartUseCase
    private let deleteCartDetailUseCase: DeleteCartDetailUseCase
    private let addProductoToCartUseCase: AddProductoToCartUseCase
    private let emptyCartUseCase: EmptyCartUseCase
    private let increaceProductInCartUseCase: IncreaceProductInCartUseCase
    private let decreaceProductInCartUseCase: DecreaceProductInCartUseCase
    
    init(getProductsInCartUseCase: GetProductsInCartUseCase, getCartUseCase: GetCartUseCase, deleteCartDetailUseCase: DeleteCartDetailUseCase, addProductoToCartUseCase: AddProductoToCartUseCase, emptyCartUseCase: EmptyCartUseCase, increaceProductInCartUseCase: IncreaceProductInCartUseCase, decreaceProductInCartUseCase: DecreaceProductInCartUseCase) {
        self.getProductsInCartUseCase = getProductsInCartUseCase
        self.getCartUseCase = getCartUseCase
        self.deleteCartDetailUseCase = deleteCartDetailUseCase
        self.addProductoToCartUseCase = addProductoToCartUseCase
        self.emptyCartUseCase = emptyCartUseCase
        self.increaceProductInCartUseCase = increaceProductInCartUseCase
        self.decreaceProductInCartUseCase = decreaceProductInCartUseCase
    }
    
    // MARK: CRUD Core Data
    func fetchCart() {
        self.cartDetailCoreData = self.getProductsInCartUseCase.execute(page: 1)
        self.cartCoreData = self.getCartUseCase.execute()
    }
    func deleteCartDetail(cartDetail: CartDetail) {
        self.deleteCartDetailUseCase.execute(cartDetail: cartDetail)
        fetchCart()
    }
    func addProductoToCarrito(product: Product) -> Bool {
        let value = self.addProductoToCartUseCase.execute(product: product)
        fetchCart()
        return value
    }
    func emptyCart () {
        self.emptyCartUseCase.execute()
        fetchCart()
    }
    /*
    func updateCartTotal() {
        self.cartRepository.updateCartTotal()
        fetchCart()
    }
     */
    func increaceProductAmount(cartDetail: CartDetail) {
        self.increaceProductInCartUseCase.execute(cartDetail: cartDetail)
        fetchCart()
    }
    func decreceProductAmount(cartDetail: CartDetail) {
        self.decreaceProductInCartUseCase.execute(cartDetail: cartDetail)
        fetchCart()
    }
    func releaseResources() {
        self.cartCoreData = nil
        self.cartDetailCoreData = []
        self.customerInCar = nil
        self.paymentType = .cash
    }
    func lazyFetchCart() {
        if cartDetailCoreData.isEmpty {
            fetchCart()
        }
    }
}
