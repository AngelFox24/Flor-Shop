//
//  LocalSaleManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

protocol SaleManager {
    func registerSale () -> Bool
    func getListSales () -> [Sale]
}

class LocalSaleManager: SaleManager {
    
    let salesContainer: NSPersistentContainer
    
    init(contenedorBDFlor: NSPersistentContainer){
        self.salesContainer = contenedorBDFlor
    }
    
    func registerSale() -> Bool {
        //Recorremos la lista de detalles del carrito para agregarlo a la venta
        if getListCart().count == 1 {
            print ("Se encontro un solo carrito")
        }else{
            print ("Se encontro varios carritos")
            return false
        }
        print ("Se procede a hacer los calculos para registrar venta")
        if let listaCarrito = getListCart().first!.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> {
            
            //Creamos un nuevo objeto venta
            let newVenta = Tb_Venta(context: salesContainer.viewContext)
            newVenta.idVenta = UUID()
            newVenta.fechaVenta = Date()
            newVenta.totalVenta = getListCart().first!.totalCarrito //Asignamos el mismo total del carrito a la venta
            
            for detalleCarrito in listaCarrito {
                if let productoInContext = salesContainer.viewContext.object(with: detalleCarrito.detalleCarrito_to_producto!.objectID) as? Tb_Producto{
                    // Crear el objeto detalleCarrito y establecer sus propiedades
                    let detalleVenta = Tb_DetalleVenta(context: salesContainer.viewContext)
                    detalleVenta.idDetalleVenta = UUID() // Genera un nuevo UUID para el detalle de la venta
                    detalleVenta.cantidad = detalleCarrito.cantidad //Asignamos la misma cantidad del producto del carrito
                    detalleVenta.subtotal = detalleCarrito.subtotal //Asignamos el mismo subtotal del producto del carrito
                    // Agregar el objeto del producto a detalle de venta
                    detalleVenta.detalleVenta_to_producto = productoInContext
                    // Agregar el objeto detalleVenta a la venta
                    detalleVenta.detalleVenta_to_venta = newVenta
                    print ("Se creo una nueva venta")
                }
            }
            print ("Se guarda los cambios")
            saveData()
            return true
        }else{
            print ("Algo salio mal y no se guardo la venta")
            return false
        }
    }
    
    func getListCart() -> [Tb_Carrito] {
        var cart:[Tb_Carrito] = []
            let request: NSFetchRequest<Tb_Carrito> = Tb_Carrito.fetchRequest()
            do{
                cart = try self.salesContainer.viewContext.fetch(request)
            }catch let error {
                print("Error fetching. \(error)")
            }
        return cart
    }
    
    func getListSales() -> [Sale] {
        var sales:[Tb_Venta] = []
            let request: NSFetchRequest<Tb_Venta> = Tb_Venta.fetchRequest()
            do{
                sales = try self.salesContainer.viewContext.fetch(request)
            }catch let error {
                print("Error fetching. \(error)")
            }
        return sales.mapToListSale()
    }
    
    func saveData () {
        do{
            try self.salesContainer.viewContext.save()
        }catch {
            print ("Error al guardar en ProductRepositoryImpl \(error)")
        }
    }
}