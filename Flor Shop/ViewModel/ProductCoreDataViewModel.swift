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
    @Published var temporalProduct: Product = Product(id: UUID(), name: "", qty: 0.0, unitCost: 0.0, unitPrice: 0.0, expirationDate: Date(), type: .Uni, url: "")
    let productRepository:  ProductRepository
    
    init(productRepository:ProductRepository) {
        self.productRepository = productRepository
        getTemporalProduct()
        fetchProducts()
    }
    
    //MARK: CRUD Core Data
    func fetchProducts () {
        productsCoreData = productRepository.getListProducts()
    }
    
    func getTemporalProduct() {
        temporalProduct = productRepository.getTemporalProduct()
    }
    
    func addProduct() -> Bool {
        let result = productRepository.saveProduct(product: temporalProduct)
        
        if(result == "Success"){
            getTemporalProduct()
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
}
