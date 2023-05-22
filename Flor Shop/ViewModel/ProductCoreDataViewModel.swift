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
    let productRepository:  ProductRepository
    
    
    init(productRepository:ProductRepository) {
        self.productRepository = productRepository
        fetchProducts()
    }
    
    
    //MARK: CRUD Core Data
    func fetchProducts () {
        productsCoreData = productRepository.getListProducts()
    }
    
    
    func addProduct(nombre_producto:String, cantidad:String, costo_unitario: String, precio_unitario: String,fecha_vencimiento: String,tipo: String,url: String) -> Bool {
      
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date =  dateFormatter.date(from: fecha_vencimiento) ?? Date()
        
        let result = productRepository.saveProduct(product: Product(name: nombre_producto,
                                                       qty: Double(cantidad) ?? 0,
                                                       unitCost: Double(costo_unitario) ?? 0 ,
                                                       unitPrice: Double(precio_unitario) ?? 0,
                                                       expirationDate: date,
                                                       type: tipo,
                                                       url: url))
        
        if(result == "Success"){
            fetchProducts()
            return true
        }else{ return false }
    }
    
    
    func reducirStock(carritoDeCompras: Car?) -> Bool {
        return productRepository.reduceStock(carritoDeCompras: carritoDeCompras)
    }
    
    
    func deleteProduct (indexSet: IndexSet) {
        productRepository.deleteProduct(indexSet: indexSet)
    }
    
 
}
