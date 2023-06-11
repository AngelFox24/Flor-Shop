//
//  CarritoCoreDataViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 1/05/23.
//
import CoreData
import Foundation


class CarritoCoreDataViewModel: ObservableObject {
    @Published var carritoCoreData: Car?
    @Published var carritoCoreDataDetails: [CartDetail] = []
    let cartRepository: CarRepository
    
    init(carRepository: CarRepository){
        self.cartRepository = carRepository
        fetchCart()
    }
    //MARK: CRUD Core Data
    func fetchCart() {
        carritoCoreDataDetails = cartRepository.getListProductInCart()
        carritoCoreData = cartRepository.getCar()
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
    
    func vaciarCarrito (){
        self.cartRepository.emptyCart()
        fetchCart()
    }
    
    func updateTotalCarrito(){
        self.cartRepository.updateTotalCart()
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
