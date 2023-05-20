//
//  ProductCoreDataViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 1/05/23.
//

import CoreData
import Foundation

class ProductCoreDataViewModel: ObservableObject {
    @Published var productsCoreData: [Tb_Producto] = []
    let repo:  ProductRepository
    
    
    init(repo:ProductRepository){
        self.repo = repo
        fetchProducts()
    }
    
    
    //MARK: CRUD Core Data
    func fetchProducts () {
        productsCoreData = repo.getListProducts()
    }
    
    
    func addProduct(nombre_producto:String, cantidad:String, costo_unitario: String, precio_unitario: String,fecha_vencimiento: String,tipo: String,url: String) -> Bool {
      
        let result = repo.saveProduct(product: Product(name: nombre_producto, qty: cantidad, unitCost: costo_unitario, unitPrice: precio_unitario, expirationDate: fecha_vencimiento, type: tipo, url: url))
        
        if(result == "Success"){
            fetchProducts()
            return true
        }else{ return false }
    }
    
    
    func reducirStock(carritoDeCompras: Tb_Carrito?) -> Bool {
        return repo.reduceStock(carritoDeCompras: carritoDeCompras)
    }
    
    
    func deleteProduct (indexSet: IndexSet) {
        repo.deleteProduct(indexSet: indexSet)
    }
    
 
}
