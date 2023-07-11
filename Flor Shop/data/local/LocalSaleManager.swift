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
    init(containerBDFlor: NSPersistentContainer) {
        self.salesContainer = containerBDFlor
    }
    func registerSale() -> Bool {
        // Recorremos la lista de detalles del carrito para agregarlo a la venta
        if getListCart().count == 1 {
            print("Se encontro un solo carrito")
        } else {
            print("Se encontro varios carritos")
            return false
        }
        print("Se procede a hacer los calculos para registrar venta")
        if let cartList = getListCart().first!.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> {
            // Creamos un nuevo objeto venta
            let newSale = Tb_Venta(context: salesContainer.viewContext)
            newSale.idVenta = UUID()
            newSale.fechaVenta = Date()
            newSale.totalVenta = getListCart().first!.totalCarrito // Asignamos el mismo total del carrito a la venta
            for cartDetail in cartList {
                if let productInContext = salesContainer.viewContext.object(with: cartDetail.detalleCarrito_to_producto!.objectID) as? Tb_Producto {
                    // Crear el objeto detalleCarrito y establecer sus propiedades
                    let saleDetail = Tb_DetalleVenta(context: salesContainer.viewContext)
                    saleDetail.idDetalleVenta = UUID() // Genera un nuevo UUID para el detalle de la venta
                    saleDetail.cantidad = cartDetail.cantidad // Asignamos la misma cantidad del producto del carrito
                    saleDetail.subtotal = cartDetail.subtotal // Asignamos el mismo subtotal del producto del carrito
                    // Agregar el objeto del producto a detalle de venta
                    saleDetail.detalleVenta_to_producto = productInContext
                    // Agregar el objeto detalleVenta a la venta
                    saleDetail.detalleVenta_to_venta = newSale
                }
            }
            print("Se guarda los cambios")
            saveData()
            return true
        } else {
            print("Algo salio mal y no se guardo la venta")
            return false
        }
    }
    func getListCart() -> [Tb_Carrito] {
        var cart: [Tb_Carrito] = []
            let request: NSFetchRequest<Tb_Carrito> = Tb_Carrito.fetchRequest()
            do {
                cart = try self.salesContainer.viewContext.fetch(request)
            } catch let error {
                print("Error fetching. \(error)")
            }
        return cart
    }
    func getListSales() -> [Sale] {
        var sales: [Tb_Venta] = []
            let request: NSFetchRequest<Tb_Venta> = Tb_Venta.fetchRequest()
            do {
                sales = try self.salesContainer.viewContext.fetch(request)
            } catch let error {
                print("Error fetching. \(error)")
            }
        return sales.mapToListSale()
    }
    func saveData () {
        do {
            try self.salesContainer.viewContext.save()
        } catch {
            print("Error al guardar en ProductRepositoryImpl \(error)")
        }
    }
}
