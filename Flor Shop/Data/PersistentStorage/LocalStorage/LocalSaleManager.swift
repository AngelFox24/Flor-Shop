//
//  LocalSaleManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

protocol SaleManager {
    func registerSale (cart: Car, paymentType:PaymentType, customerId: UUID?) -> Bool
    func sync(salesDTOs: [SaleDTO]) throws
    func payClientTotalDebt(customer: Customer) -> Bool
    func getListSales () -> [Sale]
    func getLastUpdated() -> Date?
    func getSaleDTO(cart: Car?, customer: Customer?, paymentType: PaymentType) -> SaleDTO?
    func setDefaultSubsidiary(subsidiary: Subsidiary)
    func getDefaultSubsidiary() -> Subsidiary?
    func getListSalesDetailsHistoric(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) -> [SaleDetail]
    func getListSalesDetailsGroupedByProduct(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) -> [SaleDetail]
    func getListSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) -> [SaleDetail]
    func getSalesAmount(date: Date, interval: SalesDateInterval) -> Double
    func getCostAmount(date: Date, interval: SalesDateInterval) -> Double
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Double
    func releaseResourses()
}

class LocalSaleManager: SaleManager {
    let mainContext: NSManagedObjectContext
    let sessionConfig: SessionConfig
//    var mainSubsidiaryEntity: Tb_Subsidiary?
    init(
        mainContext: NSManagedObjectContext,
        sessionConfig: SessionConfig
    ) {
        self.mainContext = mainContext
        self.sessionConfig = sessionConfig
    }
    func saveData () {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en LocalSaleManager \(error)")
            rollback()
        }
    }
    func rollback() {
        self.mainContext.rollback()
    }
    func releaseResourses() {
        self.mainSubsidiaryEntity = nil
    }
    func getLastUpdated() -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 1999, month: 1, day: 1)
        let dateFrom = calendar.date(from: components)
        var listDate: [Date?] = []
        guard let subsidiaryEntity = self.mainSubsidiaryEntity else {
            print("No se encontró sucursal")
            return dateFrom
        }
        let request: NSFetchRequest<Tb_Sale> = Tb_Sale.fetchRequest()
        let predicate = NSPredicate(format: "toSubsidiary == %@ AND updatedAt != nil", subsidiaryEntity)
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            listDate = try self.mainContext.fetch(request).map{$0.updatedAt}
        } catch let error {
            print("Error fetching. \(error)")
        }
        guard let last = listDate[0] else {
            print("Se retorna valor por defecto")
            return dateFrom
        }
        print("Se retorna valor desde la BD")
        return last
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
    func payClientTotalDebt(customer: Customer) -> Bool {
        guard let subsidiaryEntity = self.mainSubsidiaryEntity else {
            print("No se encontró sucursal")
            return false
        }
        if customer.totalDebt.cents <= 0 {
            return false
        }
        let totalDebtDB: Int = getTotalDebtByCustomer(customer: customer)
        if totalDebtDB == customer.totalDebt.cents && totalDebtDB != 0 {
            guard let customerEntity = customer.toCustomerEntity(context: self.mainContext) else {
                print("No se encontró sucursal")
                return false
            }
            let request: NSFetchRequest<Tb_Sale> = Tb_Sale.fetchRequest()
            let predicate = NSPredicate(format: "paymentType == %@ AND toSubsidiary == %@ AND toCustomer == %@", PaymentType.loan.description, subsidiaryEntity, customerEntity)
            request.predicate = predicate
            do {
                let salesDetailList = try self.mainContext.fetch(request)
                for saleDetail in salesDetailList {
                    saleDetail.paymentType = PaymentType.cash.description
                }
                customerEntity.totalDebt = 0
                customerEntity.isCreditLimit = false
                saveData()
                return true
            } catch let error {
                print("Error fetching. \(error)")
                rollback()
                return false
            }
        } else {
            print("El monto de deuda en la vista: \(customer.totalDebt) no coincide con la BD: \(totalDebtDB)")
            return false
        }
    }
    func getTotalDebtByCustomer(customer: Customer) -> Int {
        guard let subsidiaryEntity = self.mainSubsidiaryEntity else {
            print("No se encontró sucursal")
            return 0
        }
        guard let customerEntity = customer.toCustomerEntity(context: self.mainContext) else {
            print("No se encontró sucursal")
            return 0
        }
        let request = NSFetchRequest<NSDictionary>(entityName: "Tb_Sale")
        let predicate = NSPredicate(format: "paymentType == %@ AND toSubsidiary == %@ AND toCustomer == %@", PaymentType.loan.description, subsidiaryEntity, customerEntity)
        request.predicate = predicate
        
        let keyPathExpression = NSExpression(forKeyPath: "total")
        let sumExpression = NSExpression(forFunction: "sum:", arguments: [keyPathExpression])
        
        let sumDescription = NSExpressionDescription()
        sumDescription.name = "TotalDebt"
        sumDescription.expression = sumExpression
        sumDescription.expressionResultType = .doubleAttributeType
        
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [sumDescription]
        
        do {
            let result = try self.mainContext.fetch(request)
            
            // Obtiene la suma de valorVenta
            if let firstResult = result.first,
               let totalDebt = firstResult["TotalDebt"] as? Int {
                return totalDebt
            } else {
                print("No se encontraron registros de este cliente")
                return 0
            }
        } catch {
            print("Error al obtener registros del Cliente: \(error)")
            return 0
        }
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
            
            let request: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "Tb_SaleDetail")
            let predicate = NSPredicate(format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity)
            request.predicate = predicate
            
            let keyPathExpression = NSExpression(forKeyPath: "unitCost")
            let sumExpression = NSExpression(forFunction: "sum:", arguments: [keyPathExpression])

            let sumDescription = NSExpressionDescription()
            sumDescription.name = "SalesCost"
            sumDescription.expression = sumExpression
            sumDescription.expressionResultType = .doubleAttributeType

            request.resultType = .dictionaryResultType
            request.propertiesToFetch = [sumDescription]

            do {
                let result = try self.mainContext.fetch(request)
                
                if let firstResult = result.first,
                   let salesCost = firstResult["SalesCost"] as? Double {
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
        return 0
    }
    func getListSalesDetailsHistoric(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) -> [SaleDetail] {
        guard let subsidiaryEntity = self.mainSubsidiaryEntity else {
            print("No se encontró sucursal")
            return []
        }
        
        let startDate = getStartDate(date: date, interval: interval)
        let endDate = getEndDate(date: date, interval: interval)
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Tb_SaleDetail")
        fetchRequest.fetchLimit = pageSize
        fetchRequest.fetchOffset = (page - 1) * pageSize
        
        //var predicate = NSPredicate(format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity)
        var predicate = NSPredicate(format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity)
        print("Star: \(startDate), End: \(endDate)")
        if let saleEntity = sale?.toSaleEntity(context: self.mainContext) {
            print("sale exist")
            predicate = NSPredicate(format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@ AND toSale == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity, saleEntity)
        }
        fetchRequest.predicate = predicate
        
        let quantityExpression = NSExpression(forKeyPath: "quantitySold")
        let subTotalExpression = NSExpression(forKeyPath: "subtotal")
        
        let quantityExpressionDescription = NSExpressionDescription()
        quantityExpressionDescription.name = "totalQuantity"
        quantityExpressionDescription.expression = quantityExpression
        quantityExpressionDescription.expressionResultType = .integer32AttributeType
        
        let subTotalDescription = NSExpressionDescription()
        subTotalDescription.name = "totalByProduct"
        subTotalDescription.expression = subTotalExpression
        subTotalDescription.expressionResultType = .doubleAttributeType
        
        fetchRequest.propertiesToFetch = ["productName", "toSale.paymentType", "toSale.saleDate", quantityExpressionDescription, subTotalDescription]
        fetchRequest.resultType = .dictionaryResultType
        
        let sortDescriptor = getOrder(order: order)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results = try self.mainContext.fetch(fetchRequest)
            return results.compactMap { result in
                guard let productName = result["productName"] as? String,
                      let totalQuantity = result["totalQuantity"] as? Int,
                      let totalByProduct = result["totalByProduct"] as? Int else {
                    return nil
                }
                
                let paymentType: PaymentType = PaymentType.from(description: result["toSale.paymentType"] as? String ?? "")
                let saleDate: Date = result["toSale.saleDate"] as? Date ?? Date()
                
                return SaleDetail(
                    id: UUID(),
                    image: completeImageSaleDetail(productName: productName),
                    productName: productName,
                    unitType: UnitTypeEnum.unit,
                    unitCost: Money(0),
                    unitPrice: Money(0),
                    quantitySold: totalQuantity,
                    paymentType: paymentType,
                    saleDate: saleDate,
                    subtotal: Money(totalByProduct),
                    createdAt: Date(),
                    updatedAt: Date()
                )
            }
        } catch {
            print("Error al recuperar datos: \(error.localizedDescription)")
            return []
        }
    }
    func getListSalesDetailsHistoric2(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) -> [SaleDetail] {
        var salesDetailList: [SaleDetail] = []
        guard let subsidiaryEntity = self.mainSubsidiaryEntity else {
            print("No se encontró sucursal")
            return salesDetailList
        }
        
        let startDate = getStartDate(date: date, interval: interval)
        let endDate = getEndDate(date: date, interval: interval)
        
        let request: NSFetchRequest<Tb_SaleDetail> = Tb_SaleDetail.fetchRequest()
        request.fetchLimit = pageSize
        request.fetchOffset = (page - 1) * pageSize
        
        //var predicate = NSPredicate(format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity)
        var predicate = NSPredicate(format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity)
        print("Star: \(startDate), End: \(endDate)")
        if let saleEntity = sale?.toSaleEntity(context: self.mainContext) {
            print("sale exist")
            predicate = NSPredicate(format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@ AND toSale == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity, saleEntity)
        }
        request.predicate = predicate
        
        
        let sortDescriptor = getOrder(order: order)
        request.sortDescriptors = [sortDescriptor]
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
    func getListSalesDetailsGroupedByProduct(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) -> [SaleDetail] {
        guard let subsidiaryEntity = self.mainSubsidiaryEntity else {
            print("No se encontró sucursal")
            return []
        }
        let startDate = getStartDate(date: date, interval: interval)
        let endDate = getEndDate(date: date, interval: interval)
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Tb_SaleDetail")
        fetchRequest.fetchLimit = pageSize
        fetchRequest.fetchOffset = (page - 1) * pageSize
        
        // Especifica el predicado para filtrar por fecha, sucursal y venta
        var predicate = NSPredicate(format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity)
        print("Star: \(startDate), End: \(endDate)")
        if let saleEntity = sale?.toSaleEntity(context: self.mainContext) {
            predicate = NSPredicate(format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@ AND toSale == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity, saleEntity)
        }
        fetchRequest.predicate = predicate
        let quantityExpression = NSExpression(forKeyPath: "quantitySold")
        let subTotalExpression = NSExpression(forKeyPath: "subtotal")
        
        let sumQuantityExpression = NSExpression(forFunction: "sum:", arguments: [quantityExpression])
        let sumSubTotalExpression = NSExpression(forFunction: "sum:", arguments: [subTotalExpression])
        
        let sumQuantityDescription = NSExpressionDescription()
        sumQuantityDescription.name = "totalQuantity"
        sumQuantityDescription.expression = sumQuantityExpression
        sumQuantityDescription.expressionResultType = .integer32AttributeType
        
        let sumSubTotalDescription = NSExpressionDescription()
        sumSubTotalDescription.name = "totalByProduct"
        sumSubTotalDescription.expression = sumSubTotalExpression
        sumSubTotalDescription.expressionResultType = .doubleAttributeType
        
        fetchRequest.propertiesToGroupBy = ["productName"]
        fetchRequest.propertiesToFetch = ["productName", sumQuantityDescription, sumSubTotalDescription]
        fetchRequest.resultType = .dictionaryResultType
        
        let sortDescriptor = getOrder(order: order)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results = try self.mainContext.fetch(fetchRequest)
            return results.compactMap { result in
                guard let productName = result["productName"] as? String,
                      let totalQuantity = result["totalQuantity"] as? Int,
                      let totalByProduct = result["totalByProduct"] as? Int else {
                    return nil
                }
                return SaleDetail(
                    id: UUID(),
                    image: completeImageSaleDetail(productName: productName),
                    productName: productName,
                    unitType: UnitTypeEnum.unit,
                    unitCost: Money(0),
                    unitPrice: Money(0),
                    quantitySold: totalQuantity,
                    paymentType: PaymentType.cash,
                    saleDate: Date(),
                    subtotal: Money(totalByProduct),
                    createdAt: Date(),
                    updatedAt: Date()
                )
            }
        } catch {
            print("Error al recuperar datos: \(error.localizedDescription)")
            return []
        }
    }
    func completeImageSaleDetail(productName: String) -> ImageUrl? {
        let request: NSFetchRequest<Tb_SaleDetail> = Tb_SaleDetail.fetchRequest()
        let filterAtt = NSPredicate(format: "productName == %@", productName)
        let sortDescriptor = NSSortDescriptor(key: "toSale.saleDate", ascending: false)
        request.predicate = filterAtt
        request.sortDescriptors = [sortDescriptor]
        do {
            let saleDetailOut = try self.mainContext.fetch(request).first
            if let saleDetailNN = saleDetailOut, let image = saleDetailNN.toImageUrl?.toImage() {
                return image
            } else {
                return nil
            }
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    func getListSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) -> [SaleDetail] {
        guard let subsidiaryEntity = self.mainSubsidiaryEntity else {
            print("No se encontró sucursal")
            return []
        }
        let startDate = getStartDate(date: date, interval: interval)
        let endDate = getEndDate(date: date, interval: interval)
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Tb_SaleDetail")
        fetchRequest.fetchLimit = pageSize
        fetchRequest.fetchOffset = (page - 1) * pageSize
        
        var predicate = NSPredicate(format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity)
        if let saleEntity = sale?.toSaleEntity(context: self.mainContext) {
            predicate = NSPredicate(format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@ AND toSale == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity, saleEntity)
        }
        fetchRequest.predicate = predicate
        let quantityExpression = NSExpression(forKeyPath: "quantitySold")
        let subTotalExpression = NSExpression(forKeyPath: "subtotal")
        
        let sumQuantityExpression = NSExpression(forFunction: "sum:", arguments: [quantityExpression])
        let sumSubTotalExpression = NSExpression(forFunction: "sum:", arguments: [subTotalExpression])
        
        let sumQuantityDescription = NSExpressionDescription()
        sumQuantityDescription.name = "totalQuantity"
        sumQuantityDescription.expression = sumQuantityExpression
        sumQuantityDescription.expressionResultType = .integer32AttributeType
        
        let sumSubTotalDescription = NSExpressionDescription()
        sumSubTotalDescription.name = "totalByProduct"
        sumSubTotalDescription.expression = sumSubTotalExpression
        sumSubTotalDescription.expressionResultType = .doubleAttributeType
        
        fetchRequest.propertiesToGroupBy = ["toSale.toCustomer.name", "toSale.toCustomer.lastName"]
        fetchRequest.propertiesToFetch = ["toSale.toCustomer.name", "toSale.toCustomer.lastName", sumQuantityDescription, sumSubTotalDescription]
        fetchRequest.resultType = .dictionaryResultType
        
        let sortDescriptor = getOrder(order: order)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results = try self.mainContext.fetch(fetchRequest)
            return results.compactMap { result in
                guard let totalQuantity = result["totalQuantity"] as? Int64,
                      let totalByProduct = result["totalByProduct"] as? Int64 else {
                    //Si sale error en el return es porque hay error en los return de abajo
                    return nil
                }
                guard let customerName = result["toSale.toCustomer.name"] as? String else {
                    return SaleDetail(
                        id: UUID(),
                        image: nil,
                        productName: "Desconocido",
                        unitType: UnitTypeEnum.unit,
                        unitCost: Money(0),
                        unitPrice: Money(0),
                        quantitySold: Int(totalQuantity),
                        paymentType: PaymentType.cash,
                        saleDate: Date(),
                        subtotal: Money(Int(totalByProduct)),
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                }
                guard let customerLastName = result ["toSale.toCustomer.lastName"] as? String else {
                    return SaleDetail(
                        id: UUID(),
                        image: completeImageCustomer(customerName: customerName),
                        productName: customerName,
                        unitType: UnitTypeEnum.unit,
                        unitCost: Money(0),
                        unitPrice: Money(0),
                        quantitySold: Int(totalQuantity),
                        paymentType: PaymentType.cash,
                        saleDate: Date(),
                        subtotal: Money(Int(totalByProduct)),
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                }
                return SaleDetail(
                    id: UUID(),
                    image: completeImageCustomer(customerName: customerName),
                    productName: customerName + " " + customerLastName,
                    unitType: UnitTypeEnum.unit,
                    unitCost: Money(0),
                    unitPrice: Money(0),
                    quantitySold: Int(totalQuantity),
                    paymentType: PaymentType.cash,
                    saleDate: Date(),
                    subtotal: Money(Int(totalByProduct)),
                    createdAt: Date(),
                    updatedAt: Date()
                )
            }
        } catch {
            print("Error al recuperar datos: \(error.localizedDescription)")
            return []
        }
    }
    func completeImageCustomer(customerName: String) -> ImageUrl? {
        let request: NSFetchRequest<Tb_Customer> = Tb_Customer.fetchRequest()
        let filterAtt = NSPredicate(format: "name == %@", customerName)
        request.predicate = filterAtt
        do {
            let customerOut = try self.mainContext.fetch(request).first
            if let image = customerOut?.toImageUrl?.toImage() {
                return image
            } else {
                return nil
            }
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    func getOrder(order: SalesOrder) -> NSSortDescriptor {
        var sortDescriptor = NSSortDescriptor(key: "toSale.saleDate", ascending: false)
        switch order {
        case .dateAsc:
            sortDescriptor = NSSortDescriptor(key: "toSale.saleDate", ascending: false)
        case .dateDesc:
            sortDescriptor = NSSortDescriptor(key: "toSale.saleDate", ascending: true)
        case .quantityAsc:
            sortDescriptor = NSSortDescriptor(key: "totalQuantity", ascending: true)
        case .quantityDesc:
            sortDescriptor = NSSortDescriptor(key: "totalQuantity", ascending: false)
        case .incomeAsc:
            sortDescriptor = NSSortDescriptor(key: "totalByProduct", ascending: true)
        case .incomeDesc:
            sortDescriptor = NSSortDescriptor(key: "totalByProduct", ascending: false)
        }
        return sortDescriptor
    }
    func getCustomerEntityById(customerId: UUID?) -> Tb_Customer? {
        let filterAtt = NSPredicate(format: "idCustomer == %@", customerId.uuidString)
        let request: NSFetchRequest<Tb_Customer> = Tb_Customer.fetchRequest()
        request.predicate = filterAtt
        do {
            let customerEntity = try self.mainContext.fetch(request).first
            return customerEntity
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    func registerSale(cart: Car, paymentType: PaymentType, customerId: UUID?) -> Bool {
        let date: Date = Date()
        var saveChanges: Bool = true
        guard let cartEntity = cart.toCartEntity(context: self.mainContext) else {
            return false
        }
        guard cart.cartDetails.isEmpty else {
//            throw LocalStorageError.notFound("No se encontro productos en la solicitud de venta")
            print("No se encontro productos en la solicitud de venta")
            return false
        }
        guard let cartDetailEntity = cart.toCartEntity(context: self.mainContext) else {
            return false
        }
        let newSaleEntity = Tb_Sale(context: self.mainContext)
        newSaleEntity.idSale = UUID()
        newSaleEntity.toSubsidiary?.idSubsidiary = self.sessionConfig.subsidiaryId
        newSaleEntity.toEmployee?.idEmployee = self.sessionConfig.employeeId
        if let customerEntity = getCustomerById(customerId: customerId) {
            newSaleEntity.toCustomer = customerEntity
            customerEntity.lastDatePurchase = date
            if customerEntity.totalDebt == 0 {
                var calendario = Calendar.current
                calendario.timeZone = TimeZone(identifier: "UTC")!
                customerEntity.dateLimit = calendario.date(byAdding: .day, value: Int(customerEntity.creditDays), to: Date())!
            }
            if paymentType == .loan {
                customerEntity.firstDatePurchaseWithCredit = customerEntity.totalDebt == 0 ? Date() : customerEntity.firstDatePurchaseWithCredit
                customerEntity.totalDebt = customerEntity.totalDebt + Int64(cart.total)
                if customerEntity.totalDebt > customerEntity.creditLimit && customerEntity.isCreditLimitActive {
                    customerEntity.isCreditLimit = true
                } else {
                    customerEntity.isCreditLimit = false
                }
            }
        }
        newSaleEntity.paymentType = paymentType.description
        newSaleEntity.saleDate = date
        newSaleEntity.total = Int64(cart.total.cents)
        //Agregamos detalles a la venta
        for cartDetail in cart.cartDetails {
            if reduceStock(cartDetailEntity: cartDetailEntity) {
                if let productEntity = cartDetailEntity.toProduct {
                    let newSaleDetailEntity = Tb_SaleDetail(context: self.mainContext)
                    newSaleDetailEntity.idSaleDetail = UUID()
                    newSaleDetailEntity.toImageUrl = cartDetail.product.image
                    newSaleDetailEntity.productName = cartDetail.product.name
                    newSaleDetailEntity.unitCost = cartDetail.product.unitCost.cents
                    newSaleDetailEntity.unitPrice = cartDetail.product.unitPrice.cents
                    newSaleDetailEntity.quantitySold = cartDetail.quantity
                    newSaleDetailEntity.subtotal = cartDetail.subtotal.cents
                    newSaleDetailEntity.toSale = newSaleEntity
                    //Eliminamos el detalle del carrito
                    self.mainContext.delete(cartDetailEntity)
                } else {
                    saveChanges = false
                }
            } else {
                saveChanges = false
            }
        }
        cartEntity.total = 0
        if saveChanges {
            print("Se vendio correctamente")
            saveData()
        } else {
            rollback()
        }
        return saveChanges
    }
    func getEmployeeById(employeeId: UUID) -> Tb_Employee? {
        guard let subsidiaryEntity = self.mainSubsidiaryEntity else {
            print("No se encontró sucursal")
            return nil
        }
        let request: NSFetchRequest<Tb_Employee> = Tb_Employee.fetchRequest()
        let predicate = NSPredicate(format: "toSubsidiary == %@ AND idEmployee == %@", subsidiaryEntity, employeeId.uuidString)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            return try self.mainContext.fetch(request).first
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    func getCustomerById(customerId: UUID) -> Tb_Customer? {
        guard let subsidiaryEntity = self.mainSubsidiaryEntity else {
            print("No se encontró sucursal")
            return nil
        }
        let request: NSFetchRequest<Tb_Customer> = Tb_Customer.fetchRequest()
        let predicate = NSPredicate(format: "idCustomer == %@", customerId.uuidString)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            return try self.mainContext.fetch(request).first
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    func sync(salesDTOs: [SaleDTO]) throws {
        for saleDTO in salesDTOs {
            guard self.sessionConfig.subsidiaryId == saleDTO.subsidiaryId else {
                throw RepositoryError.syncFailed("La subsidiaria no es la misma")
            }
            guard saleDTO.saleDetail.isEmpty else {
                throw RepositoryError.syncFailed("El detalle de las ventas esta vacio")
            }
            let newSaleEntity = Tb_Sale(context: self.mainContext)
            newSaleEntity.idSale = saleDTO.id
            newSaleEntity.toSubsidiary?.idSubsidiary = self.sessionConfig.subsidiaryId
            newSaleEntity.toEmployee?.idEmployee = self.sessionConfig.employeeId
            if let customerId = saleDTO.customerId, let customerEntity = getCustomerById(customerId: customerId) {
                newSaleEntity.toCustomer = customerEntity
            }
            newSaleEntity.paymentType = saleDTO.paymentType
            newSaleEntity.saleDate = saleDTO.saleDate
            newSaleEntity.total = Int64(saleDTO.total)
            //Agregamos detalles a la venta
            for saleDetailDTO in saleDTO.saleDetail {
                let newSaleDetailEntity = Tb_SaleDetail(context: self.mainContext)
                newSaleDetailEntity.idSaleDetail = saleDetailDTO.id
                newSaleDetailEntity.toImageUrl?.idImageUrl = saleDetailDTO.imageUrl?.id
                newSaleDetailEntity.productName = saleDetailDTO.productName
                newSaleDetailEntity.unitCost = Int64(saleDetailDTO.unitCost)
                newSaleDetailEntity.unitPrice = Int64(saleDetailDTO.unitPrice)
                newSaleDetailEntity.quantitySold = Int64(saleDetailDTO.quantitySold)
                newSaleDetailEntity.subtotal = Int64(saleDetailDTO.subtotal)
                newSaleDetailEntity.toSale?.idSale = saleDetailDTO.saleID
            }
        }
        saveData()
    }
    func getSaleDTO(cart: Car?, customer: Customer?, paymentType: PaymentType) -> SaleDTO? {
        //Verificamos si existe subisidiaria por defecto
        guard let defaultSubsidiaryEntity = self.mainSubsidiaryEntity, let subsidiaryId = defaultSubsidiaryEntity.idSubsidiary else {
            print("No existe subisidiaria por defecto en LocalSaleManager")
            return nil
        }
        //Verificamos si existe el carrito
        guard let cartEntity = cart?.toCartEntity(context: self.mainContext) else {
            print("El carrito para la venta no existe")
            return nil
        }
        let customerId = customer?.toCustomerEntity(context: self.mainContext)?.idCustomer
        //Verificamos si el carrito pertenece a un empleado
        guard let employeeEntity = cartEntity.toEmployee, let employeeId = employeeEntity.idEmployee else {
            print("El carrito no tiene un empleado")
            return nil
        }
        //Obtenemos los detalles de los productos
        guard let cartDetailEntitySet = cartEntity.toCartDetail as? Set<Tb_CartDetail> else {
            return nil
        }
        let saleId = UUID()
        var listSaleDetails: [SaleDetailDTO] = []
        var total: Int = 0
        for cartDetail in cartDetailEntitySet {
            if let productInCart = cartDetail.toProduct {
                let product = productInCart.toProduct()
                let saleDetailDTO = SaleDetailDTO(
                    id: UUID(),
                    productName: product.name,
                    barCode: product.barCode ?? "",
                    quantitySold: product.qty,
                    subtotal: product.qty * product.unitPrice.cents,
                    unitType: product.unitType.rawValue,
                    unitCost: product.unitCost.cents,
                    unitPrice: product.unitPrice.cents,
                    saleID: saleId,
                    imageUrl: product.image?.toImageUrlDTO(),
                    createdAt: product.createdAt.description,
                    updatedAt: product.updatedAt.description
                )
                total += saleDetailDTO.subtotal
                listSaleDetails.append(saleDetailDTO)
            }
        }
        return SaleDTO(
            id: saleId,
            paymentType: paymentType.description,
            saleDate: Date(),
            total: total,
            subsidiaryId: subsidiaryId,
            customerId: customerId,
            employeeId: employeeId,
            saleDetail: listSaleDetails,
            createdAt: Date().description,
            updatedAt: Date().description
        )
    }
    private func reduceStock(saleDetail: SaleDetail) -> Bool {
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
