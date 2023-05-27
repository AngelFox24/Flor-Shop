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
        let result = productRepository.saveProduct(product: temporalProduct)
        
        if(result == "Success"){
            setDefaultProduct()
            fetchProducts()
            return true
        }else{ return false }
    }
    
    func reducirStock() -> Bool {
        let success = productRepository.reduceStock()
        fetchProducts()
        return success
    }
    
    func editProduct (product: Product) {
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
