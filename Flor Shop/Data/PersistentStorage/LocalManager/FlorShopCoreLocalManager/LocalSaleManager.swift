import Foundation
import CoreData
import FlorShopDTOs

protocol LocalSaleManager {
    func registerSale(cart: Car, paymentType: PaymentType, customerCic: String?) throws
    func sync(backgroundContext: NSManagedObjectContext, salesDTOs: [SaleClientDTO]) throws
    func getLastToken(context: NSManagedObjectContext) -> Int64
    func getSalesDetailsHistoric(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail]
    func getSalesDetailsGroupedByProduct(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail]
    func getSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail]
    func getSalesAmount(date: Date, interval: SalesDateInterval) throws -> Money
    func getCostAmount(date: Date, interval: SalesDateInterval) throws -> Money
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Money
}

class LocalSaleManagerImpl: LocalSaleManager {
    let mainContext: NSManagedObjectContext
    let sessionConfig: SessionConfig
    let className = "[LocalSaleManager]"
    init(
        mainContext: NSManagedObjectContext,
        sessionConfig: SessionConfig
    ) {
        self.mainContext = mainContext
        self.sessionConfig = sessionConfig
    }
    func getLastToken(context: NSManagedObjectContext) -> Int64 {
        let request: NSFetchRequest<Tb_Sale> = Tb_Sale.fetchRequest()
        let predicate = NSPredicate(format: "toSubsidiary.subsidiaryCic == %@ AND syncToken != nil", self.sessionConfig.subsidiaryCic)
        let sortDescriptor = NSSortDescriptor(key: "syncToken", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.fetchLimit = 1
        let lastTokenSaleDetail = self.getLastTokenForSaleDetails(context: context)
        do {
            let syncToken = try self.mainContext.fetch(request).compactMap{$0.syncToken}.first ?? 0
            return max(lastTokenSaleDetail, syncToken)
        } catch let error {
            print("Error fetching. \(error)")
            return 0
        }
    }
    func getLastTokenForSaleDetails(context: NSManagedObjectContext) -> Int64 {
        let request: NSFetchRequest<Tb_SaleDetail> = Tb_SaleDetail.fetchRequest()
        let predicate = NSPredicate(format: "toSale.toSubsidiary.subsidiaryCic == %@ AND syncToken != nil", self.sessionConfig.subsidiaryCic)
        let sortDescriptor = NSSortDescriptor(key: "syncToken", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let syncToken = try self.mainContext.fetch(request).compactMap{$0.syncToken}.first ?? 0
            return syncToken
        } catch let error {
            print("Error fetching. \(error)")
            return 0
        }
    }
    //TODO: Refactor to support only cartId, that enable to handle multiples carts for employee
    func registerSale(cart: Car, paymentType: PaymentType, customerCic: String?) throws {
        let date: Date = Date()
        guard let cartEntity = try self.sessionConfig.getCartEntityById(context: self.mainContext, cartId: cart.id) else {
            throw LocalStorageError.entityNotFound("No se encontro carrito de ventas")
        }
        guard let cartDetailsEntities = cartEntity.toCartDetail as? Set<Tb_CartDetail> else {
            throw LocalStorageError.entityNotFound("El carrito no tiene productos")
        }
        guard let employeeSubsidiaryEntity = cartEntity.toEmployeeSubsidiary else {
            print("No se pudo obtener la subsidiaria del empleado")
            rollback()
            throw LocalStorageError.entityNotFound("No se pudo obtener la subsidiaria")
        }
        guard let subsidiaryEntity = employeeSubsidiaryEntity.toSubsidiary else {
            print("No se pudo obtener la subsidiaria")
            rollback()
            throw LocalStorageError.entityNotFound("No se pudo obtener la subsidiaria")
        }
        guard cartDetailsEntities.isEmpty else {
            print("No se encontro productos en la solicitud de venta")
            throw LocalStorageError.saveFailed("No se encontro productos en la solicitud de venta")
        }
        let newSaleEntity = Tb_Sale(context: self.mainContext)
        newSaleEntity.idSale = UUID()
        newSaleEntity.toSubsidiary = subsidiaryEntity
        newSaleEntity.toEmployeeSubsidiary = employeeSubsidiaryEntity
        if let customerCic,
           let customerEntity = try self.sessionConfig.getCustomerEntityByCic(context: self.mainContext, customerCic: customerCic) {
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
            }
        }
        newSaleEntity.paymentType = paymentType.description
        newSaleEntity.saleDate = date
        //Agregamos detalles a la venta
        var total: Int64 = 0
        for cartDetailEntity in cartDetailsEntities {
            if reduceStock(cartDetailEntity: cartDetailEntity) {
                guard let productSubsidiaryEntity = cartDetailEntity.toProductSubsidiary,
                      let productEntity = productSubsidiaryEntity.toProduct else {
                    print("No se encontro el producto asociado al detalle del carrito")
                    throw LocalStorageError.saveFailed("No se encontro el producto asociado al detalle del carrito")
                }
                let newSaleDetailEntity = Tb_SaleDetail(context: self.mainContext)
                newSaleDetailEntity.idSaleDetail = UUID()
                newSaleDetailEntity.imageUrl = productEntity.imageUrl
                newSaleDetailEntity.productName = productEntity.productName
                newSaleDetailEntity.unitCost = productSubsidiaryEntity.unitCost
                newSaleDetailEntity.unitPrice = productSubsidiaryEntity.unitPrice
                newSaleDetailEntity.quantitySold = cartDetailEntity.quantityAdded
                newSaleDetailEntity.subtotal = cartDetailEntity.quantityAdded * productSubsidiaryEntity.unitPrice
                newSaleDetailEntity.toSale = newSaleEntity
                //Actualizamos contadores
                total += cartDetailEntity.quantityAdded * productSubsidiaryEntity.unitPrice
                //Eliminamos el detalle del carrito
                self.mainContext.delete(cartDetailEntity)
            } else {
                rollback()
                throw LocalStorageError.saveFailed("No se pudo reducir el stock")
            }
        }
        newSaleEntity.total = total
        print("Se vendio correctamente")
        try saveData()
    }
    func getSalesAmount(date: Date, interval: SalesDateInterval) throws -> Money {
        guard let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityByCic(
            context: self.mainContext,
            subsidiaryCic: self.sessionConfig.subsidiaryCic
        ) else {
            throw LocalStorageError.entityNotFound("No se encontro la subisidiaria")
        }
        let startDate = getStartDate(date: date, interval: interval)
        let endDate = getEndDate(date: date, interval: interval)
        let request: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: Tb_Sale.schema)
        let predicate = NSPredicate(format: "saleDate >= %@ AND saleDate <= %@ AND toSubsidiary == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity)
        request.predicate = predicate
        
        let keyPathExpression = NSExpression(forKeyPath: "total")
        let sumExpression = NSExpression(forFunction: "sum:", arguments: [keyPathExpression])

        // Configura una descripción de expresión para la solicitud de suma
        let sumDescription = NSExpressionDescription()
        sumDescription.name = "SalesAmount"
        sumDescription.expression = sumExpression
        sumDescription.expressionResultType = .integer64AttributeType

        // Asigna la descripción de expresión al fetchRequest
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [sumDescription]

        do {
            let result = try self.mainContext.fetch(request)
            
            // Obtiene la suma de valorVenta
            if let firstResult = result.first,
               let salesAmount = firstResult["SalesAmount"] as? Int64 {
                return Money(Int(salesAmount))
            } else {
                print("No se encontraron registros dentro del rango de fechas.")
                return Money(0)
            }
        } catch {
            print("Error al obtener registros dentro del rango de fechas: \(error)")
            return Money(0)
        }
    }
    func getCostAmount(date: Date, interval: SalesDateInterval) throws -> Money {
        guard let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityByCic(
            context: self.mainContext,
            subsidiaryCic: self.sessionConfig.subsidiaryCic
        ) else {
            throw LocalStorageError.entityNotFound("No se encontro la subisidiaria")
        }
        let startDate = getStartDate(date: date, interval: interval)
        let endDate = getEndDate(date: date, interval: interval)
        
        let request: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "Tb_SaleDetail")
        let predicate = NSPredicate(
            format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@",
            startDate as NSDate,
            endDate as NSDate,
            subsidiaryEntity
        )
        request.predicate = predicate
        
        let keyPathExpression = NSExpression(forKeyPath: "unitCost")
        let sumExpression = NSExpression(forFunction: "sum:", arguments: [keyPathExpression])
        
        let sumDescription = NSExpressionDescription()
        sumDescription.name = "SalesCost"
        sumDescription.expression = sumExpression
        sumDescription.expressionResultType = .integer64AttributeType
        
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [sumDescription]
        
        do {
            let result = try self.mainContext.fetch(request)
            
            if let firstResult = result.first,
               let salesCost = firstResult["SalesCost"] as? Int64 {
                return Money(Int(salesCost))
            } else {
                print("No se encontraron registros de detalles de ventas dentro del rango de fechas.")
                return Money(0)
            }
        } catch {
            print("Error al obtener registros de detalles de ventas dentro del rango de fechas: \(error)")
            return Money(0)
        }
    }
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Money {
        return Money(0)
    }
    func getSalesDetailsHistoric(
        page: Int,
        pageSize: Int,
        sale: Sale?,
        date: Date,
        interval: SalesDateInterval,
        order: SalesOrder,
        grouper: SalesGrouperAttributes
    ) throws -> [SaleDetail] {
        guard let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityByCic(
            context: self.mainContext,
            subsidiaryCic: self.sessionConfig.subsidiaryCic
        ) else {
            throw LocalStorageError.entityNotFound("No se encontro la subisidiaria")
        }
        let startDate = getStartDate(date: date, interval: interval)
        let endDate = getEndDate(date: date, interval: interval)
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Tb_SaleDetail")
        fetchRequest.fetchLimit = pageSize
        fetchRequest.fetchOffset = (page - 1) * pageSize
        var predicate = NSPredicate(
            format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@",
            startDate as NSDate,
            endDate as NSDate,
            subsidiaryEntity
        )
        print("Star: \(startDate), End: \(endDate)")
        if let saleNN = sale, let saleEntity = try self.sessionConfig.getSaleEntityById(context: self.mainContext, saleId: saleNN.id) {
            print("sale exist")
            predicate = NSPredicate(
                format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@ AND toSale == %@",
                startDate as NSDate,
                endDate as NSDate,
                subsidiaryEntity,
                saleEntity
            )
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
                      let paymentType = result["toSale.paymentType"] as? String,
                      let paymentTypeEnum = PaymentType(rawValue: paymentType),
                      let unitType = result["unitType"] as? String,
                      let unitTypeEnum = UnitType(rawValue: unitType),
                      let saleDate: Date = result["toSale.saleDate"] as? Date,
                      let totalQuantity = result["totalQuantity"] as? Int,
                      let totalByProduct = result["totalByProduct"] as? Int else {
                    return nil
                }
                let imageUrl = result["imageUrl"] as? String
                let barcode: String? = result["barcode"] as? String
                return SaleDetail(
                    id: UUID(),
                    imageUrl: imageUrl,
                    barCode: barcode,
                    productName: productName,
                    unitType: unitTypeEnum,
                    unitCost: Money(0),
                    unitPrice: Money(0),
                    quantitySold: totalQuantity,
                    paymentType: paymentTypeEnum,
                    saleDate: saleDate,
                    subtotal: Money(totalByProduct)
                )
            }
        } catch {
            print("Error al recuperar datos: \(error.localizedDescription)")
            return []
        }
    }
    func getSalesDetailsGroupedByProductBK(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail] {
        guard let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityByCic(
            context: self.mainContext,
            subsidiaryCic: self.sessionConfig.subsidiaryCic
        ) else {
            throw LocalStorageError.entityNotFound("No se encontro la subisidiaria")
        }
        let startDate = getStartDate(date: date, interval: interval)
        let endDate = getEndDate(date: date, interval: interval)
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Tb_SaleDetail")
        fetchRequest.fetchLimit = pageSize
        fetchRequest.fetchOffset = (page - 1) * pageSize
        
        // Especifica el predicado para filtrar por fecha, sucursal y venta
        var predicate = NSPredicate(format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity)
        print("Star: \(startDate), End: \(endDate)")
        if let saleNN = sale, let saleEntity = try self.sessionConfig.getSaleEntityById(context: self.mainContext, saleId: saleNN.id) {
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
                      let unitType = result["unitType"] as? String,
                      let unitTypeEnum = UnitType(rawValue: unitType),
                      let totalQuantity = result["totalQuantity"] as? Int,
                      let totalByProduct = result["totalByProduct"] as? Int else {
                    return nil
                }
                if let saleDetailIdS = result["idSaleDetail"] as? String {
                    print("Hay idS!!!!! \(saleDetailIdS)")
                } else if let saleDetailId = result["idSaleDetail"] as? UUID {
                    print("Hay id!!!!! \(saleDetailId.uuidString)")
                } else {
                    print("No hay Id pipipi")
                }
                let imageUrl = result["imageUrl"] as? String
                let barcode: String? = result["barcode"] as? String
                return SaleDetail(
                    id: UUID(),
                    imageUrl: imageUrl,
                    barCode: barcode,
                    productName: productName,
                    unitType: unitTypeEnum,
                    unitCost: Money(0),
                    unitPrice: Money(0),
                    quantitySold: totalQuantity,
                    paymentType: PaymentType.cash,
                    saleDate: Date(),
                    subtotal: Money(totalByProduct)
                )
            }
        } catch {
            print("Error al recuperar datos: \(error.localizedDescription)")
            return []
        }
    }
    func getSalesDetailsGroupedByProduct(
        page: Int,
        pageSize: Int,
        sale: Sale?,
        date: Date,
        interval: SalesDateInterval,
        order: SalesOrder,
        grouper: SalesGrouperAttributes
    ) throws -> [SaleDetail] {
        guard let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityByCic(
            context: self.mainContext,
            subsidiaryCic: self.sessionConfig.subsidiaryCic
        ) else {
            throw LocalStorageError.entityNotFound("No se encontro la subisidiaria")
        }
        let startDate = getStartDate(date: date, interval: interval)
        let endDate = getEndDate(date: date, interval: interval)
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Tb_SaleDetail")
        fetchRequest.fetchLimit = pageSize
        fetchRequest.fetchOffset = (page - 1) * pageSize
        
        // Especifica el predicado para filtrar por fecha, sucursal y venta
        var predicate = NSPredicate(format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity)
        print("Star: \(startDate), End: \(endDate)")
        if let saleNN = sale, let saleEntity = try self.sessionConfig.getSaleEntityById(context: self.mainContext, saleId: saleNN.id) {
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
        
        fetchRequest.propertiesToGroupBy = ["toImageUrl.idImageUrl", "productName"]
        fetchRequest.propertiesToFetch = ["toImageUrl.idImageUrl", "productName", sumQuantityDescription, sumSubTotalDescription]
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
                let imageUrl = result["imageUrl"] as? String
                return SaleDetail(
                    id: UUID(),
                    imageUrl: imageUrl,
                    productName: productName,
                    unitType: UnitType.unit,
                    unitCost: Money(0),
                    unitPrice: Money(0),
                    quantitySold: totalQuantity,
                    paymentType: PaymentType.cash,
                    saleDate: Date(),
                    subtotal: Money(totalByProduct)
                )
            }
        } catch {
            print("Error al recuperar datos: \(error.localizedDescription)")
            return []
        }
    }
    func getSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail] {
        guard let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityByCic(
            context: self.mainContext,
            subsidiaryCic: self.sessionConfig.subsidiaryCic
        ) else {
            throw LocalStorageError.entityNotFound("No se encontro la subisidiaria")
        }
        let startDate = getStartDate(date: date, interval: interval)
        let endDate = getEndDate(date: date, interval: interval)
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Tb_SaleDetail")
        fetchRequest.fetchLimit = pageSize
        fetchRequest.fetchOffset = (page - 1) * pageSize
        
        var predicate = NSPredicate(format: "toSale.saleDate >= %@ AND toSale.saleDate <= %@ AND toSale.toSubsidiary == %@", startDate as NSDate, endDate as NSDate, subsidiaryEntity)
        if let saleNN = sale, let saleEntity = try self.sessionConfig.getSaleEntityById(context: self.mainContext, saleId: saleNN.id) {
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
                let imageUrl = result["imageUrl"] as? String
                guard let customerName = result["toSale.toCustomer.name"] as? String else {
                    return SaleDetail(
                        id: UUID(),
                        imageUrl: nil,
                        productName: "Desconocido",
                        unitType: UnitType.unit,
                        unitCost: Money(0),
                        unitPrice: Money(0),
                        quantitySold: Int(totalQuantity),
                        paymentType: PaymentType.cash,
                        saleDate: Date(),
                        subtotal: Money(Int(totalByProduct))
                    )
                }
                guard let customerLastName = result ["toSale.toCustomer.lastName"] as? String else {
                    return SaleDetail(
                        id: UUID(),
                        imageUrl: imageUrl,
                        productName: customerName,
                        unitType: UnitType.unit,
                        unitCost: Money(0),
                        unitPrice: Money(0),
                        quantitySold: Int(totalQuantity),
                        paymentType: PaymentType.cash,
                        saleDate: Date(),
                        subtotal: Money(Int(totalByProduct))
                    )
                }
                return SaleDetail(
                    id: UUID(),
                    imageUrl: imageUrl,
                    productName: customerName + " " + customerLastName,
                    unitType: UnitType.unit,
                    unitCost: Money(0),
                    unitPrice: Money(0),
                    quantitySold: Int(totalQuantity),
                    paymentType: PaymentType.cash,
                    saleDate: Date(),
                    subtotal: Money(Int(totalByProduct))
                )
            }
        } catch {
            print("Error al recuperar datos: \(error.localizedDescription)")
            return []
        }
    }
    func sync(backgroundContext: NSManagedObjectContext, salesDTOs: [SaleClientDTO]) throws {
        print("Entro a sale unos: \(salesDTOs.count)")
        for saleDTO in salesDTOs {
            print("Se procesara saleDTO: \(saleDTO.subsidiaryCic)")
            guard self.sessionConfig.subsidiaryCic == saleDTO.subsidiaryCic else {
                print("La subsidiaria no es la misma")
                throw RepositoryError.syncFailed("La subsidiaria no es la misma")
            }
            guard !saleDTO.saleDetail.isEmpty else {
                print("El detalle de las ventas esta vacio")
                throw RepositoryError.syncFailed("El detalle de las ventas esta vacio")
            }
            guard let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityByCic(
                context: backgroundContext,
                subsidiaryCic: saleDTO.subsidiaryCic
            ) else {
                print("La subsidiaria no existe en la BD local: \(saleDTO.subsidiaryCic)")
                throw LocalStorageError.entityNotFound("La subsidiaria no existe en la BD local")
            }
            guard let employeeSubsidiaryEntity = try self.sessionConfig.getEmployeeSubsidiaryEntityByCic(
                context: backgroundContext,
                employeeCic: saleDTO.employeeCic
            ) else {
                print("El empleado no existe")
                throw LocalStorageError.entityNotFound("El empleado no existe")
            }
            if let saleEntity = try self.sessionConfig.getSaleEntityById(context: backgroundContext, saleId: saleDTO.id) {
                guard !saleDTO.isEquals(to: saleEntity) else {
                    print("\(className) No se actualizo, porque es el mismo")
                    continue
                }
                //Update
                print("Se actualiza sale")
                saleEntity.paymentType = saleDTO.paymentType.description
                saleEntity.updatedAt = saleDTO.updatedAt
                saleEntity.syncToken = saleDTO.syncToken
                try saveData(context: backgroundContext)
            } else {
                //Create
                print("Se crea sale")
                let newSaleEntity = Tb_Sale(context: backgroundContext)
                newSaleEntity.idSale = saleDTO.id
                newSaleEntity.toSubsidiary = subsidiaryEntity
                newSaleEntity.toEmployeeSubsidiary = employeeSubsidiaryEntity
                if let customerCic = saleDTO.customerCic {
                    newSaleEntity.toCustomer = try self.sessionConfig.getCustomerEntityByCic(context: backgroundContext, customerCic: customerCic)
                }
                newSaleEntity.paymentType = saleDTO.paymentType.rawValue
                newSaleEntity.saleDate = saleDTO.saleDate
                newSaleEntity.syncToken = saleDTO.syncToken
                newSaleEntity.createdAt = saleDTO.createdAt
                newSaleEntity.updatedAt = saleDTO.updatedAt
                newSaleEntity.total = Int64(saleDTO.total)
                for saleDetailDTO in saleDTO.saleDetail {
                    let newSaleDetailEntity = Tb_SaleDetail(context: backgroundContext)
                    newSaleDetailEntity.idSaleDetail = saleDetailDTO.id
                    newSaleDetailEntity.imageUrl = saleDetailDTO.imageUrl
                    newSaleDetailEntity.productName = saleDetailDTO.productName
                    newSaleDetailEntity.unitCost = Int64(saleDetailDTO.unitCost)
                    newSaleDetailEntity.unitPrice = Int64(saleDetailDTO.unitPrice)
                    newSaleDetailEntity.quantitySold = Int64(saleDetailDTO.quantitySold)
                    newSaleDetailEntity.subtotal = Int64(saleDetailDTO.subtotal)
                    newSaleDetailEntity.toSale = newSaleEntity
                    newSaleDetailEntity.syncToken = saleDetailDTO.syncToken
                    newSaleDetailEntity.createdAt = saleDetailDTO.createdAt
                    newSaleDetailEntity.updatedAt = saleDetailDTO.updatedAt
                    try saveData(context: backgroundContext)
                }
                try saveData(context: backgroundContext)
            }
        }
    }
    //MARK: Private Functions
    private func saveData() throws {
        do {
            try self.mainContext.save()
        } catch {
            rollback()
            let cusError: String = "\(className): \(error.localizedDescription)"
            throw LocalStorageError.saveFailed(cusError)
        }
    }
    private func rollback() {
        self.mainContext.rollback()
    }
    private func saveData(context: NSManagedObjectContext) throws {
        do {
            try context.save()
        } catch {
            rollback(context: context)
            let cusError: String = "\(className) - BackgroundContext: \(error.localizedDescription)"
            throw LocalStorageError.saveFailed(cusError)
        }
    }
    private func rollback(context: NSManagedObjectContext) {
        context.rollback()
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
        guard let productSubsidiaryEntity = cartDetailEntity.toProductSubsidiary else {
            print("Detalle no contiene producto")
            return false
        }
        if productSubsidiaryEntity.quantityStock >= cartDetailEntity.quantityAdded {
            productSubsidiaryEntity.quantityStock -= cartDetailEntity.quantityAdded
            return true
        } else {
            print("No hay stock suficiente")
            return false
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
