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
    @Published var customerInCar: Customer? = Customer.getDummyCustomer()
    private let cartRepository: CarRepository
    init(carRepository: CarRepository) {
        self.cartRepository = carRepository
    }
    // MARK: CRUD Core Data
    func fetchCart() {
        cartDetailCoreData = cartRepository.getListProductInCart()
        cartCoreData = cartRepository.getCart()
    }
    // Elimina un producto del carrito de compras
    func deleteCartDetail(cartDetail: CartDetail) {
        self.cartRepository.deleteCartDetail(cartDetail: cartDetail)
        fetchCart()
    }
    func addProductoToCarrito(product: Product) -> Bool {
        let value = self.cartRepository.addProductoToCarrito(product: product)
        fetchCart()
        return value
    }
    func emptyCart () {
        self.cartRepository.emptyCart()
        fetchCart()
    }
    func updateCartTotal() {
        self.cartRepository.updateCartTotal()
        fetchCart()
    }
    func increaceProductAmount (cartDetail: CartDetail) {
        self.cartRepository.increaceProductAmount(cartDetail: cartDetail)
        fetchCart()
    }
    func decreceProductAmount (cartDetail: CartDetail) {
        self.cartRepository.decreceProductAmount(cartDetail: cartDetail)
        fetchCart()
    }
    func lazyFetchCart() {
        if cartDetailCoreData.isEmpty {
            fetchCart()
        }
    }
}
