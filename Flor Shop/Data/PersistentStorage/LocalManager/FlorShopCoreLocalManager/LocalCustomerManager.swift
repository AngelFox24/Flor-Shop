import Foundation
import CoreData
import FlorShopDTOs

protocol LocalCustomerManager {
    func save(customer: Customer) throws
    func payClientTotalDebt(customer: Customer) throws -> Bool
    func sync(backgroundContext: NSManagedObjectContext, customersDTOs: [CustomerClientDTO]) throws
    func getLastToken() -> Int64
    func getLastToken(context: NSManagedObjectContext) -> Int64
    func getCustomers(seachText: String, order: CustomerOrder, filter: CustomerFilterAttributes, page: Int, pageSize: Int) -> [Customer]
    func getSalesDetailHistory(customer: Customer, page: Int, pageSize: Int) -> [SaleDetail]
    func getCustomer(customer: Customer) throws -> Customer?
}

class LocalCustomerManagerImpl: LocalCustomerManager {
    let sessionConfig: SessionConfig
    let mainContext: NSManagedObjectContext
    let className = "[LocalCustomerManager]"
    init(
        mainContext: NSManagedObjectContext,
        sessionConfig: SessionConfig
    ) {
        self.mainContext = mainContext
        self.sessionConfig = sessionConfig
    }
    func getLastToken() -> Int64 {
        return self.getLastToken(context: self.mainContext)
    }
    func getLastToken(context: NSManagedObjectContext) -> Int64 {
        let request: NSFetchRequest<Tb_Customer> = Tb_Customer.fetchRequest()
        let predicate = NSPredicate(format: "toCompany.companyCic == %@ AND syncToken != nil", self.sessionConfig.companyCic)
        let sortDescriptor = NSSortDescriptor(key: "syncToken", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let syncToken = try self.mainContext.fetch(request).compactMap{$0.syncToken}.first
            return syncToken ?? 0
        } catch let error {
            print("Error fetching. \(error)")
            return 0
        }
    }
    func sync(backgroundContext: NSManagedObjectContext, customersDTOs: [CustomerClientDTO]) throws {
        for customerDTO in customersDTOs {
            guard self.sessionConfig.companyCic == customerDTO.companyCic else {
                throw LocalStorageError.syncFailed("La compañia no es la misma")
            }
            guard let companyEntity = try self.sessionConfig.getCompanyEntityByCic(context: backgroundContext, companyCic: customerDTO.companyCic) else {
                rollback(context: backgroundContext)
                throw LocalStorageError.entityNotFound("La compañia no existe en la bd local")
            }
            if let customerEntity = try self.sessionConfig.getCustomerEntityByCic(context: backgroundContext, customerCic: customerDTO.customerCic) {
                guard !customerDTO.isEquals(to: customerEntity) else {
                    print("\(className) No se actualiza, es lo mismo")
                    continue
                }
                customerEntity.creditLimit = Int64(customerDTO.creditLimit)
                customerEntity.creditScore = Int64(customerDTO.creditScore)
                customerEntity.creditDays = Int64(customerDTO.creditDays)
                customerEntity.isCreditLimitActive = customerDTO.isCreditLimitActive
                customerEntity.dateLimit = customerDTO.dateLimit
                customerEntity.isDateLimitActive = customerDTO.isDateLimitActive
                customerEntity.lastName = customerDTO.lastName
                customerEntity.name = customerDTO.name
                customerEntity.phoneNumber = customerDTO.phoneNumber
                customerEntity.imageUrl = customerDTO.imageUrl
                customerEntity.lastDatePurchase = customerDTO.lastDatePurchase
                customerEntity.firstDatePurchaseWithCredit = customerDTO.firstDatePurchaseWithCredit
                customerEntity.totalDebt = Int64(customerDTO.totalDebt)
                customerEntity.syncToken = customerDTO.syncToken
                customerEntity.createdAt = customerDTO.createdAt
                customerEntity.updatedAt = customerDTO.updatedAt
                try saveData(context: backgroundContext)
            } else {
                let newCustomerEntity = Tb_Customer(context: backgroundContext)
                newCustomerEntity.customerCic = customerDTO.customerCic
                newCustomerEntity.creditLimit = Int64(customerDTO.creditLimit)
                newCustomerEntity.creditScore = Int64(customerDTO.creditScore)
                newCustomerEntity.creditDays = Int64(customerDTO.creditDays)
                newCustomerEntity.isCreditLimitActive = customerDTO.isCreditLimitActive
                newCustomerEntity.dateLimit = customerDTO.dateLimit
                newCustomerEntity.isDateLimitActive = customerDTO.isDateLimitActive
                newCustomerEntity.lastName = customerDTO.lastName
                newCustomerEntity.name = customerDTO.name
                newCustomerEntity.phoneNumber = customerDTO.phoneNumber
                newCustomerEntity.imageUrl = customerDTO.imageUrl
                newCustomerEntity.toCompany = companyEntity
                newCustomerEntity.lastDatePurchase = customerDTO.lastDatePurchase
                newCustomerEntity.firstDatePurchaseWithCredit = customerDTO.firstDatePurchaseWithCredit
                newCustomerEntity.totalDebt = Int64(customerDTO.totalDebt)
                newCustomerEntity.syncToken = customerDTO.syncToken
                newCustomerEntity.createdAt = customerDTO.createdAt
                newCustomerEntity.updatedAt = customerDTO.updatedAt
                try saveData(context: backgroundContext)
            }
        }
    }
    func payClientTotalDebt(customer: Customer) throws -> Bool {
        if customer.totalDebt.cents <= 0 {
            return false
        }
        let totalDebtDB: Int = try getTotalDebtByCustomer(customer: customer)
        if totalDebtDB == customer.totalDebt.cents && totalDebtDB != 0 {
            guard let customerCic = customer.customerCic,
                  let customerEntity = try self.sessionConfig.getCustomerEntityByCic(context: self.mainContext, customerCic: customerCic) else {
                print("No se encontró cliente")
                return false
            }
            let request: NSFetchRequest<Tb_Sale> = Tb_Sale.fetchRequest()
            let predicate = NSPredicate(
                format: "paymentType == %@ AND toSubsidiary.subsidiaryCic == %@ AND toCustomer.customerCic == %@",
                PaymentType.loan.description,
                self.sessionConfig.subsidiaryCic,
                customerCic
            )
            request.predicate = predicate
            do {
                let salesDetailList = try self.mainContext.fetch(request)
                for saleDetail in salesDetailList {
                    saleDetail.paymentType = PaymentType.cash.description
                }
                customerEntity.totalDebt = 0
                try saveData()
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
    private func getTotalDebtByCustomer(customer: Customer) throws -> Int {
        guard let customerCic = customer.customerCic else {
            throw LocalStorageError.entityNotFound("No se encontró el CIC del cliente")
        }
        let request = NSFetchRequest<NSDictionary>(entityName: "Tb_Sale")
        let predicate = NSPredicate(
            format: "paymentType == %@ AND toSubsidiary.subsidiaryCic == %@ AND toCustomer.customerCic == %@",
            PaymentType.loan.description,
            self.sessionConfig.subsidiaryCic,
            customerCic
        )
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
    func save(customer: Customer) throws {
        if let customerCic = customer.customerCic,
           let customerEntity = try self.sessionConfig.getCustomerEntityByCic(context: self.mainContext, customerCic: customerCic) { //Busqueda por id
            customerEntity.name = customer.name
            customerEntity.lastName = customer.lastName
            customerEntity.creditDays = Int64(customer.creditDays)
            customerEntity.creditLimit = Int64(customer.creditLimit.cents)
            customerEntity.isCreditLimitActive = customer.isCreditLimitActive
            customerEntity.isDateLimitActive = customer.isDateLimitActive
            customerEntity.phoneNumber = customer.phoneNumber
            customerEntity.imageUrl = customer.imageUrl
            //TODO: Segregate this
            if customer.isDateLimitActive && customerEntity.totalDebt > 0, let firstDatePurchaseWithCredit = customerEntity.firstDatePurchaseWithCredit {
                var calendar = Calendar.current
                calendar.timeZone = TimeZone(identifier: "UTC")!
                customerEntity.dateLimit = calendar.date(byAdding: .day, value: Int(customerEntity.creditDays), to: firstDatePurchaseWithCredit)!
                let finalDelDia = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
            }
            try saveData()
        } else if customerExist(customer: customer) { //Comprobamos si existe el mismo empleado por otros atributos
            rollback()
        } else { //Creamos un nuevo empleado
            let newCustomerEntity = Tb_Customer(context: self.mainContext)
            newCustomerEntity.customerCic = UUID().uuidString
            newCustomerEntity.name = customer.name
            newCustomerEntity.lastName = customer.lastName
            newCustomerEntity.creditDays = Int64(customer.creditDays)
            newCustomerEntity.creditLimit = Int64(customer.creditLimit.cents)
            newCustomerEntity.creditScore = 50
            newCustomerEntity.dateLimit = Date()
            newCustomerEntity.phoneNumber = customer.phoneNumber
            newCustomerEntity.imageUrl = customer.imageUrl
            newCustomerEntity.totalDebt = 0
            newCustomerEntity.isDateLimitActive = customer.isDateLimitActive
            newCustomerEntity.isCreditLimitActive = customer.isCreditLimitActive
            newCustomerEntity.toCompany?.companyCic = self.sessionConfig.companyCic
            try saveData()
        }
    }
    func getCustomer(customer: Customer) throws -> Customer? {
        if let customerCic = customer.customerCic,
           let customerEntity = try self.sessionConfig.getCustomerEntityByCic(context: self.mainContext, customerCic: customerCic) {
            return try customerEntity.toCustomer()
        } else {
            return nil
        }
    }
    func getCustomers(seachText: String, order: CustomerOrder, filter: CustomerFilterAttributes, page: Int, pageSize: Int) -> [Customer] {
        var cutomerList: [Customer] = []
        let request: NSFetchRequest<Tb_Customer> = Tb_Customer.fetchRequest()
        request.fetchLimit = pageSize
        request.fetchOffset = (page - 1) * pageSize
        
        var predicate1 = NSPredicate(format: "toCompany.companyCic == %@", self.sessionConfig.companyCic)
        if seachText != "" {
            predicate1 = NSPredicate(
                format: "(name CONTAINS[c] %@ OR lastName CONTAINS[c] %@) AND toCompany.companyCic == %@",
                seachText,
                seachText,
                self.sessionConfig.companyCic
            )
        }
        let predicate2 = getFilter(filter: filter)
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicate1, predicate2])
        
        request.predicate = compoundPredicate
        let sortDescriptor = getOrder(order: order)
        request.sortDescriptors = [sortDescriptor]
        do {
            cutomerList = try self.mainContext.fetch(request).compactMap { try? $0.toCustomer() }
        } catch let error {
            print("Error fetching. \(error)")
        }
        return cutomerList
    }
    func getSalesDetailHistory(customer: Customer, page: Int, pageSize: Int) -> [SaleDetail] {
        var salesCutomerList: [SaleDetail] = []
        let request: NSFetchRequest<Tb_SaleDetail> = Tb_SaleDetail.fetchRequest()
        request.fetchLimit = pageSize
        request.fetchOffset = (page - 1) * pageSize
        guard let customerCic = customer.customerCic else {
//            throw LocalStorageError.invalidInput("customerCic is nil")
            return []
        }
        let predicate = NSPredicate(
            format: "toSale.toCustomer.toCompany.companyCic == %@ AND toSale.toCustomer.customerCic == %@",
            self.sessionConfig.companyCic,
            customerCic
        )
        request.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "toSale.saleDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        do {
            salesCutomerList = try self.mainContext.fetch(request).compactMap { try? $0.toSaleDetail() }
        } catch let error {
            print("Error fetching. \(error)")
        }
        return salesCutomerList
    }
    func customerExist(customer: Customer) -> Bool {
        let filterAtt: NSPredicate
        if let lastName = customer.lastName {
            filterAtt = NSPredicate(format: "name == %@ AND lastName == %@", customer.name, lastName)
        } else {
            filterAtt = NSPredicate(format: "name == %@", customer.name)
        }
        let request: NSFetchRequest<Tb_Customer> = Tb_Customer.fetchRequest()
        request.predicate = filterAtt
        do {
            let total = try self.mainContext.fetch(request).count
            return total == 0 ? false : true
        } catch let error {
            print("Error fetching. \(error)")
            return false
        }
    }
    //MARK: Private Funtions
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
    private func getFilter(filter: CustomerFilterAttributes) -> NSPredicate {
        var filterAtt = NSPredicate(format: "name != ''")
        switch filter {
        case .allCustomers:
            filterAtt = NSPredicate(format: "name != ''")
        case .onTime:
            let today = Date()
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(identifier: "UTC")!
            let inicioDelDia = calendar.startOfDay(for: today)
            filterAtt = NSPredicate(format: "dateLimit > %@", inicioDelDia as NSDate)
        case .dueByDate:
            let today = Date()
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(identifier: "UTC")!
            let inicioDelDia = calendar.startOfDay(for: today)
            filterAtt = NSPredicate(format: "dateLimit < %@", inicioDelDia as NSDate)
        case .excessAmount:
            filterAtt = NSPredicate(format: "totalDebt >= creditLimit")
        }
        return filterAtt
    }
    private func getOrder(order: CustomerOrder) -> NSSortDescriptor {
        var sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        switch order {
        case .nameAsc:
            sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        case .nextDate:
            sortDescriptor = NSSortDescriptor(key: "dateLimit", ascending: true)
        case .quantityAsc:
            sortDescriptor = NSSortDescriptor(key: "totalDebt", ascending: true)
        case .quantityDesc:
            sortDescriptor = NSSortDescriptor(key: "totalDebt", ascending: false)
        }
        return sortDescriptor
    }
}
