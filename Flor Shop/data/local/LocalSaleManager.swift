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
    let mainContext: NSManagedObjectContext
    func registerSale() -> Bool {
        // Recorremos la lista de detalles del carrito para agregarlo a la venta
        if getListCart().count == 1 {
            print("Se encontro un solo carrito")
        } else {
            print("Se encontro varios carritos")
            return false
        }
        print("Se procede a hacer los calculos para registrar venta")
        if let cartDetailList = getListCart().first!.toCartDetail as? Set<Tb_CartDetail> {
            // Creamos un nuevo objeto venta
            let newSale = Tb_Sale(context: mainContext)
            newSale.idSale = UUID()
            newSale.saleDate = Date()
            newSale.total = getListCart().first!.total // Asignamos el mismo total del carrito a la venta
            for cartDetail in cartDetailList {
                /*
                for productInList in cartDetail {
                    if let productInContext = mainContext.object(with: productInList) as? Tb_Product {
                        // Crear el objeto detalleCarrito y establecer sus propiedades
                        let saleDetail = Tb_SaleDetail(context: mainContext)
                        saleDetail.idSaleDetail = UUID() // Genera un nuevo UUID para el detalle de la venta
                        saleDetail.quantitySold = cartDetail.quantityAdded // Asignamos la misma cantidad del producto del carrito
                        saleDetail.subtotal = cartDetail.subtotal // Asignamos el mismo subtotal del producto del carrito
                        // Agregar el objeto detalleVenta a la venta
                        saleDetail.toSale = newSale
                    }
                }
                 */
            }
            print("Se guarda los cambios")
            saveData()
            return true
        } else {
            print("Algo salio mal y no se guardo la venta")
            return false
        }
    }
    func getListCart() -> [Tb_Cart] {
        var cart: [Tb_Cart] = []
            let request: NSFetchRequest<Tb_Cart> = Tb_Cart.fetchRequest()
            do {
                cart = try self.mainContext.fetch(request)
            } catch let error {
                print("Error fetching. \(error)")
            }
        return cart
    }
    func getListSales() -> [Sale] {
        var sales: [Tb_Sale] = []
            let request: NSFetchRequest<Tb_Sale> = Tb_Sale.fetchRequest()
            do {
                sales = try self.mainContext.fetch(request)
            } catch let error {
                print("Error fetching. \(error)")
            }
        return sales.mapToListSale()
    }
    func saveData () {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en ProductRepositoryImpl \(error)")
        }
    }
}
