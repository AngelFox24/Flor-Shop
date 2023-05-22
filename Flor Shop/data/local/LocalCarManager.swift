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
}
