//
//  ProductCoreDataViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 1/05/23.
//

import CoreData
import Foundation

class ProductCoreDataViewModel: ObservableObject {
    @Published var productsCoreData: [Product] = []
    @Published var temporalProduct: Product = Product()
    let productRepository:  ProductRepository
    
    init(productRepository:ProductRepository) {
        self.productRepository = productRepository
        fetchProducts()
    }
    
    //MARK: CRUD Core Data
    func fetchProducts () {
        productsCoreData = productRepository.getListProducts()
    }
    
    func setDefaultProduct() {
        temporalProduct = Product()
    }
    
    func addProduct() -> Bool {
        print ("Se presiono addProduct")
        print ("El nombre del producto a agregar es \(temporalProduct.name)")
        let result = productRepository.saveProduct(product: temporalProduct)
        
        if(result == "Success"){
            print ("Se añadio correctamente")
            setDefaultProduct()
            fetchProducts()
            return true
        }else{
            print (result)
            return false
        }
    }
    
    func reducirStock() -> Bool {
        let success = productRepository.reduceStock()
        fetchProducts()
        return success
    }
    
    func editProduct (product: Product) {
        print ("Se presiono edit product con nombre: \(product.name)")
        self.temporalProduct = product
    }
    
    func filterProducts(word: String){
        if word == "" {
            fetchProducts()
        }else {
            productsCoreData = self.productRepository.filterProducts(word: word)
        }
    }
    
    func setPrimaryFilter(filter: PrimaryOrder, word: String) {
        productRepository.setPrimaryFilter(filter: filter)
        filterProducts(word: word)
    }
}
