//
//  LocalSaleManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

protocol SaleManager {
    func registerSale (cart: Car?) -> Bool
    func getListSales () -> [Sale]
    func setDefaultSubsidiary(subsidiary: Subsidiary)
    func getDefaultSubsidiary() -> Subsidiary?
}

class LocalSaleManager: SaleManager {
    let mainContext: NSManagedObjectContext
    var mainSubsidiaryEntity: Tb_Subsidiary?
    init(mainContext: NSManagedObjectContext) {
        self.mainContext = mainContext
    }
    func saveData () {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en LocalSaleManager \(error)")
        }
    }
    func rollback() {
        self.mainContext.rollback()
    }
    func setDefaultSubsidiary(subsidiary: Subsidiary) {
        guard let subsidiaryEntity: Tb_Subsidiary = subsidiary.toSubsidiaryEntity(context: self.mainContext) else {
            print("No se pudo asingar sucursar default")
            return
        }
        self.mainSubsidiaryEntity = subsidiaryEntity
    }
    func getDefaultSubsidiary() -> Subsidiary? {
        return self.mainSubsidiaryEntity?.toSubsidiary()
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
    func registerSale(cart: Car?) -> Bool {
        var saveChanges: Bool = true
        //Verificamos si existe subisidiaria por defecto
        guard let defaultSubsidiaryEntity = self.mainSubsidiaryEntity else {
            print("No existe subisidiaria por defecto en LocalSaleManager")
            return false
        }
        //Verificamos si existe el carrito
        guard let cartEntity = cart?.toCartEntity(context: self.mainContext) else {
            print("El carrito para la venta no existe")
            return false
        }
        //Verificamos si el carrito pertenece a un empleado
        guard let employeeEntity = cartEntity.toEmployee else {
            print("El carrito no tiene un empleado")
            return false
        }
        //Obtenemos los detalles de los productos
        guard let cartDetailEntitySet = cartEntity.toCartDetail as? Set<Tb_CartDetail> else {
            return false
        }
        if !cartDetailEntitySet.isEmpty {
            let newSaleEntity = Tb_Sale(context: self.mainContext)
            newSaleEntity.idSale = UUID()
            newSaleEntity.toSubsidiary = defaultSubsidiaryEntity
            newSaleEntity.toEmployee = employeeEntity
            newSaleEntity.paymentType = "Efectivo"
            newSaleEntity.saleDate = Date()
            newSaleEntity.total = cartEntity.total
            //Agregamos detalles a la venta
            for cartDetailEntity in cartDetailEntitySet {
                if reduceStock(cartDetailEntity: cartDetailEntity) {
                    if let productEntity = cartDetailEntity.toProduct {
                        let newSaleDetailEntity = Tb_SaleDetail(context: self.mainContext)
                        newSaleDetailEntity.idSaleDetail = UUID()
                        newSaleDetailEntity.toImageUrl = productEntity.toImageUrl
                        newSaleDetailEntity.productName = productEntity.productName
                        newSaleDetailEntity.unitCost = productEntity.unitCost
                        newSaleDetailEntity.unitPrice = productEntity.unitPrice
                        newSaleDetailEntity.quantitySold = cartDetailEntity.quantityAdded
                        newSaleDetailEntity.subtotal = cartDetailEntity.subtotal
                        newSaleDetailEntity.toSale = newSaleEntity
                    } else {
                        saveChanges = false
                    }
                } else {
                    saveChanges = false
                }
            }
        } else {
            saveChanges = false
        }
        if saveChanges {
            print("Se vendio correctamente")
            saveData()
        } else {
            rollback()
        }
        return saveChanges
    }
    private func reduceStock(cartDetailEntity: Tb_CartDetail) -> Bool {
        guard let productEntity = cartDetailEntity.toProduct else {
            print("Detalle no contiene producto")
            return false
        }
        if productEntity.quantityStock >= cartDetailEntity.quantityAdded {
            productEntity.quantityStock -= cartDetailEntity.quantityAdded
            return true
        } else {
            return false
        }
    }
}
