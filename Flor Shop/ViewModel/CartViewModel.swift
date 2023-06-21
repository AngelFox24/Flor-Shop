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
    let cartRepository: CarRepository
    
    init(carRepository: CarRepository){
        self.cartRepository = carRepository
        fetchCart()
    }
    //MARK: CRUD Core Data
    func fetchCart() {
        cartDetailCoreData = cartRepository.getListProductInCart()
        cartCoreData = cartRepository.getCar()
    }
    
    //Elimina un producto del carrito de compras
    func deleteProduct(product: Product) {
        self.cartRepository.deleteProduct(product: product)
        fetchCart()
    }
    
    func addProductoToCarrito(product: Product){
        self.cartRepository.addProductoToCarrito(product: product)
        fetchCart()
    }
    
    func emptyCart (){
        self.cartRepository.emptyCart()
        fetchCart()
    }
    
    func updateCartTotal(){
        self.cartRepository.updateCartTotal()
        fetchCart()
    }
    
    func increaceProductAmount (product: Product){
        self.cartRepository.increaceProductAmount(product: product)
        fetchCart()
    }
    
    func decreceProductAmount (product: Product){
        self.cartRepository.decreceProductAmount(product: product)
        fetchCart()
    }
}
