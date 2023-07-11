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
    @Published var temporalProduct: Product = Product()
    let productRepository: ProductRepository
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
        fetchProducts()
    }
    // MARK: CRUD Core Data
    func fetchProducts () {
        productsCoreData = productRepository.getListProducts()
    }
    func setDefaultProduct() {
        temporalProduct = Product()
    }
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
    func reduceStock() -> Bool {
        let success = productRepository.reduceStock()
        fetchProducts()
        return success
    }
    func editProduct (product: Product) {
        self.temporalProduct = product
        calcProfitMargin()
    }
    func filterProducts(word: String) {
        if word == "" {
            fetchProducts()
        } else {
            productsCoreData = self.productRepository.filterProducts(word: word)
        }
    }
    func setPrimaryFilter(filter: PrimaryOrder, word: String) {
        productRepository.setPrimaryFilter(filter: filter)
        filterProducts(word: word)
    }
    func calcProfitMargin() {
        print("Se llamo a la funcion calcular profit")
        if ((temporalProduct.unitPrice - temporalProduct.unitCost) > 0.0) && (temporalProduct.unitPrice > 0) && (temporalProduct.unitCost > 0) {
            temporalProduct.profitMargin = (temporalProduct.unitPrice - temporalProduct.unitCost) / temporalProduct.unitCost
            print("Se calculo profit: \(temporalProduct.profitMargin)")
        } else {
            temporalProduct.profitMargin = 0.0
        }
    }
}
