//
//  LocalSaleManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

protocol LocalSaleManager {
    func registerSale (cart: Car, paymentType:PaymentType, customerId: UUID?) throws
    func sync(salesDTOs: [SaleDTO]) throws
    func payClientTotalDebt(customer: Customer) throws -> Bool
    func getLastUpdated() -> Date
    func getSalesDetailsHistoric(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail]
    func getSalesDetailsGroupedByProduct(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail]
    func getSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail]
    func getSalesAmount(date: Date, interval: SalesDateInterval) throws -> Double
    func getCostAmount(date: Date, interval: SalesDateInterval) throws -> Double
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Double
}

class LocalSaleManagerImpl: LocalSaleManager {
    let mainContext: NSManagedObjectContext
    let sessionConfig: SessionConfig
    init(
        mainContext: NSManagedObjectContext,
        sessionConfig: SessionConfig
    ) {
        self.mainContext = mainContext
        self.sessionConfig = sessionConfig
    }
    func registerSale(cart: Car, paymentType: PaymentType, customerId: UUID?) throws {
        let date: Date = Date()
        guard let cartEntity = self.sessionConfig.getCartEntityById(context: self.mainContext, cartId: cart.id) else {
            throw LocalStorageError.notFound("No se encontro carrito de ventas")
        }
        guard cart.cartDetails.isEmpty else {
            print("No se encontro productos en la solicitud de venta")
            throw LocalStorageError.notFound("No se encontro productos en la solicitud de venta")
        }
        let newSaleEntity = Tb_Sale(context: self.mainContext)
        newSaleEntity.idSale = UUID()
        newSaleEntity.toSubsidiary?.idSubsidiary = self.sessionConfig.subsidiaryId
        newSaleEntity.toEmployee?.idEmployee = self.sessionConfig.employeeId
        if let customerId = customerId, let customerEntity = self.sessionConfig.getCustomerEntityById(context: self.mainContext, customerId: customerId) {
            newSaleEntity.toCustomer = customerEntity
            customerEntity.lastDatePurchase = date
            if customerEntity.totalDebt == 0 {
                var calendario = Calendar.current
                calendario.timeZone = TimeZone(identifier: "UTC")!
                customerEntity.dateLimit = calendario.date(byAdding: .day, value: Int(customerEntity.creditDays), to: Date())!
            }
            if paymentType == .loan {
                customerEntity.firstDatePurchaseWithCredit = customerEntity.totalDebt == 0 ? Date() : customerEntity.firstDatePurchaseWithCredit
                customerEntity.totalDebt = customerEntity.totalDebt + Int64(cart.total.cents)
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
            if let cartDetailEntity = self.sessionConfig.getCartDetailEntityById(context: self.mainContext, cartDetailId: cartDetail.id) {
                if reduceStock(cartDetailEntity: cartDetailEntity) {
                    let newSaleDetailEntity = Tb_SaleDetail(context: self.mainContext)
                    newSaleDetailEntity.idSaleDetail = UUID()
                    newSaleDetailEntity.toImageUrl?.idImageUrl = cartDetail.product.image?.id
                    newSaleDetailEntity.productName = cartDetail.product.name
                    newSaleDetailEntity.unitCost = Int64(cartDetail.product.unitCost.cents)
                    newSaleDetailEntity.unitPrice = Int64(cartDetail.product.unitPrice.cents)
                    newSaleDetailEntity.quantitySold = Int64(cartDetail.quantity)
                    newSaleDetailEntity.subtotal = Int64(cartDetail.subtotal.cents)
                    newSaleDetailEntity.toSale = newSaleEntity
                    //Eliminamos el detalle del carrito
                    self.mainContext.delete(cartDetailEntity)
                } else {
                    rollback()
                    throw LocalStorageError.notFound("No se pudo reducir el stock")
                }
            } else {
                rollback()
                throw LocalStorageError.notFound("No se encontro el detalle del carrito")
            }
        }
        cartEntity.total = 0
        print("Se vendio correctamente")
        saveData()
    }
    func getLastUpdated() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 1999, month: 1, day: 1)
        let dateFrom = calendar.date(from: components)
        let request: NSFetchRequest<Tb_Sale> = Tb_Sale.fetchRequest()
        let predicate = NSPredicate(format: "toSubsidiary.idSubsidiary == %@ AND updatedAt != nil", self.sessionConfig.subsidiaryId.uuidString)
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let date = try self.mainContext.fetch(request).compactMap{$0.updatedAt}.first
            guard let dateNN = date else {
                return dateFrom!
            }
            return dateNN
        } catch let error {
            print("Error fetching. \(error)")
            return dateFrom!
        }
    }
    func payClientTotalDebt(customer: Customer) throws -> Bool {
        guard let subsidiaryEntity = self.sessionConfig.getSubsidiaryEntityById(context: self.mainContext, subsidiaryId: self.sessionConfig.subsidiaryId) else {
            throw LocalStorageError.notFound("No se encontro la subisidiaria")
        }
        if customer.totalDebt.cents <= 0 {
            return false
        }
        let totalDebtDB: Int = try getTotalDebtByCustomer(customer: customer)
        if totalDebtDB == customer.totalDebt.cents && totalDebtDB != 0 {
            guard let customerEntity = self.sessionConfig.getCustomerEntityById(context: self.mainContext, customerId: customer.id) else {
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
    func getTotalDebtByCustomer(customer: Customer) throws -> Int {
        guard let subsidiaryEntity = self.sessionConfig.getSubsidiaryEntityById(context: self.mainContext, subsidiaryId: self.sessionConfig.subsidiaryId) else {
            throw LocalStorageError.notFound("No se encontro la subisidiaria")
        }
        guard let customerEntity = self.sessionConfig.getCustomerEntityById(context: self.mainContext, customerId: customer.id) else {
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
    func getSalesAmount(date: Date, interval: SalesDateInterval) throws -> Double {
        guard let subsidiaryEntity = self.sessionConfig.getSubsidiaryEntityById(context: self.mainContext, subsidiaryId: self.sessionConfig.subsidiaryId) else {
            throw LocalStorageError.notFound("No se encontro la subisidiaria")
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
    func getCostAmount(date: Date, interval: SalesDateInterval) throws -> Double {
        guard let subsidiaryEntity = self.sessionConfig.getSubsidiaryEntityById(context: self.mainContext, subsidiaryId: self.sessionConfig.subsidiaryId) else {
            throw LocalStorageError.notFound("No se encontro la subisidiaria")
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
    func getSalesDetailsHistoric(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail] {
        guard let subsidiaryEntity = self.sessionConfig.getSubsidiaryEntityById(context: self.mainContext, subsidiaryId: self.sessionConfig.subsidiaryId) else {
            throw LocalStorageError.notFound("No se encontro la subisidiaria")
        }
        let startDate = getStartDate(date: date, interval: interval)
        let endDate = getEndDate(date: date, interval: interval)
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Tb_SaleDetail")
        fetchRequest.fetchLimit = pageSize
        fetchRequest.fetchOffset = (page - 1) * pageSize
        var predicate = NSPredicate(format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity)
        print("Star: \(startDate), End: \(endDate)")
        if let saleNN = sale, let saleEntity = self.sessionConfig.getSaleEntityById(context: self.mainContext, saleId: saleNN.id) {
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
    func getSalesDetailsGroupedByProduct(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail] {
        guard let subsidiaryEntity = self.sessionConfig.getSubsidiaryEntityById(context: self.mainContext, subsidiaryId: self.sessionConfig.subsidiaryId) else {
            throw LocalStorageError.notFound("No se encontro la subisidiaria")
        }
        let startDate = getStartDate(date: date, interval: interval)
        let endDate = getEndDate(date: date, interval: interval)
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Tb_SaleDetail")
        fetchRequest.fetchLimit = pageSize
        fetchRequest.fetchOffset = (page - 1) * pageSize
        
        // Especifica el predicado para filtrar por fecha, sucursal y venta
        var predicate = NSPredicate(format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity)
        print("Star: \(startDate), End: \(endDate)")
        if let saleNN = sale, let saleEntity = self.sessionConfig.getSaleEntityById(context: self.mainContext, saleId: saleNN.id) {
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
    func getSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail] {
        guard let subsidiaryEntity = self.sessionConfig.getSubsidiaryEntityById(context: self.mainContext, subsidiaryId: self.sessionConfig.subsidiaryId) else {
            throw LocalStorageError.notFound("No se encontro la subisidiaria")
        }
        let startDate = getStartDate(date: date, interval: interval)
        let endDate = getEndDate(date: date, interval: interval)
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Tb_SaleDetail")
        fetchRequest.fetchLimit = pageSize
        fetchRequest.fetchOffset = (page - 1) * pageSize
        
        var predicate = NSPredicate(format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity)
        if let saleNN = sale, let saleEntity = self.sessionConfig.getSaleEntityById(context: self.mainContext, saleId: saleNN.id) {
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
            if let customerId = saleDTO.customerId, let customerEntity = self.sessionConfig.getCustomerEntityById(context: self.mainContext, customerId: customerId) {
                newSaleEntity.toCustomer = customerEntity
            }
            newSaleEntity.paymentType = saleDTO.paymentType
            newSaleEntity.saleDate = saleDTO.saleDate
            newSaleEntity.total = Int64(saleDTO.total)
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
    //MARK: Private Functions
    private func saveData () {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en LocalSaleManager \(error)")
            rollback()
        }
    }
    private func rollback() {
        self.mainContext.rollback()
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
    private func completeImageCustomer(customerName: String) -> ImageUrl? {
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
    private func completeImageSaleDetail(productName: String) -> ImageUrl? {
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
    private func getOrder(order: SalesOrder) -> NSSortDescriptor {
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
}
