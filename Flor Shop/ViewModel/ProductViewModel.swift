//
//  ProductCoreDataViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 1/05/23.
//

import CoreData
import Foundation

class ProductViewModel: ObservableObject {
    @Published var productsCoreData: [Product] = []
    let productRepository: ProductRepository
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
        fetchProducts()
    }
    // MARK: CRUD Core Data
    func fetchProducts () {
        productsCoreData = productRepository.getListProducts()
    }
    /*
    func addProduct() -> Bool {
        let result = productRepository.saveProduct(product: temporalProduct)
        if result == "Success" {
            print("Se añadio correctamente")
            setDefaultProduct()
            fetchProducts()
            return true
        } else {
            print(result)
            return false
        }
    }
     */
    func reduceStock() -> Bool {
        let success = productRepository.reduceStock()
        fetchProducts()
        return success
    }
    func filterProducts(word: String) {
        if word == "" {
            fetchProducts()
        } else {
            productsCoreData = self.productRepository.filterProducts(word: word)
        }
    }
    func setOrder(order: PrimaryOrder) {
        productRepository.setOrder(order: order)
    }
    func setFilter(filter: ProductsFilterAttributes) {
        productRepository.setFilter(filter: filter)
    }
}
