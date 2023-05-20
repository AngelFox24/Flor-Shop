//
//  Repository.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 20/05/23.
//

import Foundation


//protocol
protocol ProductRepository {
    func saveProduct(product:Product)-> String
    func getListProducts() -> [Tb_Producto]
    func reduceStock(carritoDeCompras: Tb_Carrito?) -> Bool
    func deleteProduct(indexSet: IndexSet) -> Bool
}
