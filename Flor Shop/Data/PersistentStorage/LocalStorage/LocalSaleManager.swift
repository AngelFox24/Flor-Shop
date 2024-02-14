//
//  LocalSaleManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

protocol SaleManager {
    func registerSale (cart: Car?, customer: Customer?) -> Bool
    func getListSales () -> [Sale]
    func setDefaultSubsidiary(subsidiary: Subsidiary)
    func getDefaultSubsidiary() -> Subsidiary?
    func getListSalesDetails(page: Int, pageSize: Int, sale: Sale?) -> [SaleDetail]
    func getSalesAmount(date: Date, interval: SalesDateInterval) -> Double
    func getCostAmount(date: Date, interval: SalesDateInterval) -> Double
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Double
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
    private func getStartDate(date: Date, interval: SalesDateInterval) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var startDateComponent = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        startDateComponent.hour = 0
        startDateComponent.minute = 0
        startDateComponent.second = 0
        
        switch interval {
        case .diary:
            break
        case .monthly:
            startDateComponent.day = 1
        case .yearly:
            startDateComponent.day = 1
            startDateComponent.month = 1
        }
        return calendar.date(from: startDateComponent)!
    }
    private func getEndDate(date: Date, interval: SalesDateInterval) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var endDateComponent = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        endDateComponent.hour = 23
        endDateComponent.minute = 59
        endDateComponent.second = 59
        
        switch interval {
        case .diary:
            break
        case .monthly:
            endDateComponent.day = 0
            endDateComponent.month! += 1
        case .yearly:
            endDateComponent.day = 0
            endDateComponent.month = 1
            endDateComponent.year! += 1
        }
        return calendar.date(from: endDateComponent)!
    }
    func getSalesAmount(date: Date, interval: SalesDateInterval) -> Double {
        guard let subsidiaryEntity = self.mainSubsidiaryEntity else {
            print("No se encontró sucursal")
            return 0
        }
        let startDate = getStartDate(date: date, interval: interval)
        let endDate = getEndDate(date: date, interval: interval)
        print("Star: \(startDate) End: \(endDate)")
        let request: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "Tb_Sale")
        let predicate = NSPredicate(format: "saleDate >= %@ AND saleDate <= %@ AND toSubsidiary == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity)
        request.predicate = predicate
        
        let keyPathExpression = NSExpression(forKeyPath: "total")
        let sumExpression = NSExpression(forFunction: "sum:", arguments: [keyPathExpression])

        // Configura una descripción de expresión para la solicitud de suma
        let sumDescription = NSExpressionDescription()
        sumDescription.name = "SalesAmount"
        sumDescription.expression = sumExpression
        sumDescription.expressionResultType = .doubleAttributeType

        // Asigna la descripción de expresión al fetchRequest
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [sumDescription]

        do {
            let result = try self.mainContext.fetch(request)
            
            // Obtiene la suma de valorVenta
            if let firstResult = result.first,
               let salesAmount = firstResult["SalesAmount"] as? Double {
                print("La suma de Total Ventas dentro del rango de fechas es:", salesAmount)
                return salesAmount
            } else {
                print("No se encontraron registros dentro del rango de fechas.")
                return 0
            }
        } catch {
            print("Error al obtener registros dentro del rango de fechas: \(error)")
            return 0
        }
    }
    func getCostAmount(date: Date, interval: SalesDateInterval) -> Double {
        guard let subsidiaryEntity = self.mainSubsidiaryEntity else {
                print("No se encontró la sucursal")
                return 0
            }
            
            let startDate = getStartDate(date: date, interval: interval)
            let endDate = getEndDate(date: date, interval: interval)
            print("Inicio: \(startDate) Fin: \(endDate)")
            
            let request: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "Tb_SaleDetail")
            let predicate = NSPredicate(format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity)
            request.predicate = predicate
            
            let keyPathExpression = NSExpression(forKeyPath: "unitCost")
            let sumExpression = NSExpression(forFunction: "sum:", arguments: [keyPathExpression])

            // Configura una descripción de expresión para la solicitud de suma
            let sumDescription = NSExpressionDescription()
            sumDescription.name = "SalesCost"
            sumDescription.expression = sumExpression
            sumDescription.expressionResultType = .doubleAttributeType

            // Asigna la descripción de expresión al fetchRequest
            request.resultType = .dictionaryResultType
            request.propertiesToFetch = [sumDescription]

            do {
                let result = try self.mainContext.fetch(request)
                
                // Obtiene la suma de los costos de venta dentro del rango de fechas
                if let firstResult = result.first,
                   let salesCost = firstResult["SalesCost"] as? Double {
                    print("La suma de los costos de venta dentro del rango de fechas es:", salesCost)
                    return salesCost
                } else {
                    print("No se encontraron registros de detalles de ventas dentro del rango de fechas.")
                    return 0
                }
            } catch {
                print("Error al obtener registros de detalles de ventas dentro del rango de fechas: \(error)")
                return 0
            }
    }
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Double {
        return 9.2
    }
    func getListSalesDetails(page: Int, pageSize: Int, sale: Sale?) -> [SaleDetail] {
        var salesDetailList: [SaleDetail] = []
        guard let _ = self.mainSubsidiaryEntity else {
            print("No se encontró sucursal")
            return salesDetailList
        }
        let request: NSFetchRequest<Tb_SaleDetail> = Tb_SaleDetail.fetchRequest()
        request.fetchLimit = pageSize
        request.fetchOffset = (page - 1) * pageSize
        
        if let saleEntity = sale?.toSaleEntity(context: self.mainContext) {
            let predicate = NSPredicate(format: "toSale == %@", saleEntity)
            request.predicate = predicate
        }
        //Ordenamiento por fecha veremos si es necesario
        /*
         let sortDescriptor = getOrderFilter(order: primaryOrder)
         request.sortDescriptors = [sortDescriptor]
         */
        do {
            salesDetailList = try self.mainContext.fetch(request).mapToSaleDetailList()
        } catch let error {
            print("Error fetching. \(error)")
        }
        return salesDetailList
    }

    func registerSale(cart: Car?, customer: Customer?) -> Bool {
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
            if let customerEntity = customer?.toCustomerEntity(context: self.mainContext) {
                newSaleEntity.toCustomer = customerEntity
            }
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
                        //Eliminamos el detalle del carrito
                        self.mainContext.delete(cartDetailEntity)
                        print("Se registro una venta: \(productEntity.productName)")
                    } else {
                        saveChanges = false
                    }
                } else {
                    saveChanges = false
                }
            }
            cartEntity.total = 0.0
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
            print("No hay stock suficiente")
            return false
        }
    }
}
