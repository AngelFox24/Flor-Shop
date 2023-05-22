//
//  LocalProductManager.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 21/05/23.
//

import Foundation
import CoreData

//protocol
protocol ProductManager {
    func saveProduct(product:Product)-> String
    func getListProducts() -> [Product]
    func reduceStock(carritoDeCompras: Tb_Carrito?) -> Bool
    func deleteProduct(indexSet: IndexSet) -> Bool
}

class LocalProductManager: ProductManager {
    
    let productsContainer: NSPersistentContainer
    
    init(contenedorBDFlor: NSPersistentContainer){
        self.productsContainer = contenedorBDFlor
    }
    
    func getListProducts() -> [Product] {
        var productList: [Tb_Producto] = []
        let request: NSFetchRequest<Tb_Producto> = Tb_Producto.fetchRequest()
        do{
            productList = try self.productsContainer.viewContext.fetch(request)
        } catch let error {
            print("Error fetching. \(error)")
        }
        
        return productList.mapToListProduct()
    }
    
    func saveProduct(product: Product) -> String {
        var message = ""
        if product.isProductNameValid(),
           product.isCantidadValid(),
           product.isCostoUnitarioValid(),
           product.isPrecioUnitarioValid(),
           product.isFechaVencimientoValid(),
           product.isURLValid() {
            
            _ = product.toProductEntity(context: productsContainer.viewContext)
            saveData()
            message = "Success"
            
        }else{
            if !product.isProductNameValid(){
                message = "El nombre del producto esta mal \(product.name)"
            }
            else if !product.isCantidadValid(){
                message = "La cantidad y el tipo esta mal \(product.qty) \(product.type)"
            }
            else if !product.isCostoUnitarioValid(){
                message = "El costo unitario esta mal \(product.unitCost)"
            }
            else if !product.isPrecioUnitarioValid(){
                message = "El precio unitario esta mal \(product.unitPrice)"
            }
            else if !product.isFechaVencimientoValid(){
                message = "La fecha de vencimiento esta mal \(product.expirationDate)"
            }
            else if !product.isURLValid(){
                message = "La URL esta mal \(product.url)"
            }
        }
        return message
    }
    
    func reduceStock(carritoDeCompras: Tb_Carrito?) -> Bool {
        var guardarCambios:Bool = true
        if let listaCarrito = carritoDeCompras?.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> {
            for detalleCarrito in listaCarrito {
                let cantidadReducida:Double = detalleCarrito.cantidad
                let productosFiltrados = getListProducts().mapToListProductEntity(context: productsContainer.viewContext).filter { $0.idProducto == detalleCarrito.detalleCarrito_to_producto?.idProducto }
                if let productoEncontrado = productosFiltrados.first {
                    print ("Contexto del producto filtrado \(String(describing: productoEncontrado.managedObjectContext))")
                    print("El nombre: \(String(describing: productoEncontrado.nombreProducto)) Cantidad Stock Antes: \(productoEncontrado.cantidadStock)")
                    if productoEncontrado.cantidadStock >= cantidadReducida {
                        productoEncontrado.cantidadStock -= cantidadReducida
                        print("Se ha disminuido el producto, Cantidad Despues: \(productoEncontrado.cantidadStock)")
                    }else{
                        guardarCambios = false
                    }
                }else {
                    guardarCambios = false
                }
            }
        }
        if guardarCambios {
            saveData()
        }else{
            print ("Eliminamos los cambios")
            self.productsContainer.viewContext.rollback()
        }
        return guardarCambios
    }
    
    func deleteProduct(indexSet: IndexSet) -> Bool {
        
        do{
            try self.productsContainer.viewContext.save()
            return true
        }catch let error {
            print("Error saving. \(error)")
            return false
        }
    }
    
    func saveData () {
        do{
            try self.productsContainer.viewContext.save()
        }catch {
            print ("Error al guardar en ProductRepositoryImpl \(error)")
        }
    }
}
