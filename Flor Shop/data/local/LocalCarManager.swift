//
//  LocalCarManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

//protocol
protocol CarManager {
    func getCar() -> Car
    func deleteProduct(product: Product)
    func addProductoToCarrito(product: Product)
    func emptyCart()
    func updateTotalCart()
    func increaceProductAmount(product: Product)
    func decreceProductAmount(product: Product)
}

class LocalCarManager: CarManager {
    let carContainer: NSPersistentContainer
    
    init(contenedorBDFlor: NSPersistentContainer){
        self.carContainer = contenedorBDFlor
    }
    
    func saveData () {
        do{
            try self.carContainer.viewContext.save()
        }catch {
            print ("Error al guardar en ProductRepositoryImpl \(error)")
        }
    }
    
    func getCar() -> Car {
        var car: Tb_Carrito? = nil
        let request: NSFetchRequest<Tb_Carrito> = Tb_Carrito.fetchRequest()
        do{
            car = try self.carContainer.viewContext.fetch(request).first
            if car == nil {
                let idCarrito = UUID()
                let fechaCarrito = Date()
                let totalCarrito = 0.0
                
                car = Tb_Carrito(context: self.carContainer.viewContext)
                car!.idCarrito = idCarrito
                car!.fechaCarrito = fechaCarrito
                car!.totalCarrito = totalCarrito
                
                saveData()
                print("Se creo un nuevo carrito exitosamente \(idCarrito)")
            }
        }catch let error{
            print("Error al recuperar el carrito de productos \(error)")
        }
        //TODO: Este codigo puede dar error xd
        return car!.mapToCar()
    }
    
    func deleteProduct(product: Product) {
        guard let carrito = carritoCoreData, let detalleCarrito = carrito.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> else {
            return
        }
        
        let detalleAEliminar = detalleCarrito.filter { $0.detalleCarrito_to_producto?.idProducto == productoEntity.idProducto }
        if let detalle = detalleAEliminar.first {
            carrito.removeFromCarrito_to_detalleCarrito(detalle)
        }
        updateTotalCarrito()
        saveCarritoProducts()
        fetchCarrito()
    }
    
    func addProductoToCarrito(product: Product) {
        guard let carrito = carritoCoreData else {
            return
        }
        let context = carritoContainer.viewContext
        
        // Obtener el objeto productoEntity del mismo contexto que el carrito
        let productoInContext = context.object(with: productoEntity.toProductEntity(context: context).objectID) as! Tb_Producto
        
        // Crear el objeto detalleCarrito y establecer sus propiedades
        let detalleCarrito = Tb_DetalleCarrito(context: context)
        detalleCarrito.idDetalleCarrito = UUID() // Genera un nuevo UUID para el detalle del carrito
        //detalleCarrito.detalleCarrito_to_carrito = carrito // Asigna el ID del carrito existente
        detalleCarrito.cantidad = 1
        detalleCarrito.subtotal = productoInContext.precioUnitario * detalleCarrito.cantidad
        // Agregar el objeto producto al detalle carrito
        detalleCarrito.detalleCarrito_to_producto = productoInContext
        // Agregar el objeto detalleCarrito al carrito
        detalleCarrito.detalleCarrito_to_carrito = carrito
        
        updateTotalCarrito()
        fetchCarrito()
        saveCarritoProducts()
    }
    
    func emptyCart() {
        carritoCoreData?.carrito_to_detalleCarrito = nil
        
        updateTotalCarrito()
        fetchCarrito()
        saveCarritoProducts()
    }
    
    func updateTotalCart() {
        guard let carrito = carritoCoreData, let detalleCarrito = carrito.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> else {
            return
        }
        var Total:Double = 0.0
        for producto in detalleCarrito {
            print("Producto nombre: \(String(describing: producto.detalleCarrito_to_producto?.nombreProducto)) y su precioUnitario: \(String(describing: producto.detalleCarrito_to_producto?.precioUnitario))")
            print("Total antes \(Total)")
            Total += producto.cantidad * (producto.detalleCarrito_to_producto?.precioUnitario ?? 0.0)
            print("Total despues \(Total)")
        }
        carrito.totalCarrito = Total
        fetchCarrito()
    }
    
    func increaceProductAmount (product: Product){
        print("Se presiono incrementar cantidad")
        guard let carrito = carritoCoreData, let detalleCarrito = carrito.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> else {
            return
        }
        
        let detalleAAgregar = detalleCarrito.filter { $0.detalleCarrito_to_producto?.idProducto == productoEntity.idProducto }
        if let detalle = detalleAAgregar.first {
            print("El nombre: \(String(describing: detalle.detalleCarrito_to_producto?.nombreProducto)) Cantidad Antes: \(detalle.cantidad)")
            detalle.cantidad += 1.0
            print("Cantidad Despues: \(detalle.cantidad)")
        }
        updateTotalCarrito()
        fetchCarrito()
        saveCarritoProducts()
    }
    
    func decreceProductAmount(product: Product){
        print("Se presiono reducir cantidad")
        guard let carrito = carritoCoreData, let detalleCarrito = carrito.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> else {
            return
        }
        
        let detalleAAgregar = detalleCarrito.filter { $0.detalleCarrito_to_producto?.idProducto == productoEntity.idProducto }
        if let detalle = detalleAAgregar.first {
            print("El nombre: \(String(describing: detalle.detalleCarrito_to_producto?.nombreProducto)) Cantidad Antes: \(detalle.cantidad)")
            detalle.cantidad -= 1.0
            print("Cantidad Despues: \(detalle.cantidad)")
        }
        updateTotalCarrito()
        fetchCarrito()
        saveCarritoProducts()
    }
}
