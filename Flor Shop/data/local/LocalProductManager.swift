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
    func getTemporalProduct() -> Product
    func reduceStock() -> Bool
    func deleteProduct(indexSet: IndexSet) -> Bool
    func filterProducts(word: String) -> [Product]
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
            
            if let productInContext = product.toProductEntity(context: productsContainer.viewContext) {
                productInContext.nombreProducto = product.name
                productInContext.cantidadStock = product.qty
                productInContext.costoUnitario = product.unitCost
                productInContext.fechaVencimiento = product.expirationDate
                productInContext.precioUnitario = product.unitPrice
                productInContext.tipoMedicion = product.type.description
                productInContext.url = product.url
                print ("Se edito producto en LocalProductManager")
            }else {
                _ = product.toNewProductEntity(context: productsContainer.viewContext)
                print ("Se creo nuevo producto en LocalProductManager")
            }
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
    
    func getListCart() -> Tb_Carrito? {
        var cart:Tb_Carrito?
            let request: NSFetchRequest<Tb_Carrito> = Tb_Carrito.fetchRequest()
            do{
                cart = try self.productsContainer.viewContext.fetch(request).first
            }catch let error {
                print("Error fetching. \(error)")
            }
        return cart
    }
    
    func reduceStock() -> Bool {
        var guardarCambios:Bool = true
        if let listaCarrito = getListCart()?.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> {
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
    
    func getTemporalProduct() -> Product {
        return Product(id: UUID(), name: "", qty: 0.0, unitCost: 0.0, unitPrice: 0.0, expirationDate: Date(), type: .Uni, url: "https://falabella.scene7.com/is/image/FalabellaPE/19316385_1?wid=180")
    }
    
    func filterProducts(word: String) -> [Product] {
        var productos:[Product] = []
        let fetchRequest: NSFetchRequest<Tb_Producto> = Tb_Producto.fetchRequest()
        let predicado = NSPredicate(format: "nombreProducto CONTAINS[c] %@", word)
        fetchRequest.predicate = predicado
        do {
            // Ejecutar la consulta y obtener los resultados
            let productosBD = try self.productsContainer.viewContext.fetch(fetchRequest)
            productos = productosBD.mapToListProduct()
            return productos
        } catch {
            print("Error al ejecutar la consulta: \(error.localizedDescription)")
            return productos
        }
    }
}
