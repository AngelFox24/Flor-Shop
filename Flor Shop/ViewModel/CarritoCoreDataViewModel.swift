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
    let cartRepository: CarRepository
    
    init(carRepository: CarRepository){
        self.cartRepository = carRepository
        fetchCart()
    }
    //MARK: CRUD Core Data
    func fetchCart() {
        carritoCoreData = cartRepository.getCar()
    }
    
    //Elimina un producto del carrito de compras
    func deleteProduct(product: Product) {
        self.cartRepository.deleteProduct(product: product)
    }
    
    func addProductoToCarrito(product: Product){
        self.cartRepository.addProductoToCarrito(product: product)
        fetchCart()
    }
    
    func vaciarCarrito (){
        self.cartRepository.emptyCart()
    }
    
    func updateTotalCarrito(){
        self.cartRepository.updateTotalCart()
    }
    
    func increaceProductAmount (product: Product){
        self.cartRepository.increaceProductAmount(product: product)
    }
    
    func decreceProductAmount (product: Product){
        self.cartRepository.decreceProductAmount(product: product)
    }
    
    func getListProductInCart () -> [Product]{
        return self.cartRepository.getListProductInCart()
    }
}
