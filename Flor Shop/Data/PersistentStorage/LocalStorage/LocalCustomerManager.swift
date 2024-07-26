//
//  LocalCustomerManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol LocalCustomerManager {
    func getLastUpdated() throws -> Date?
    func sync(customersDTOs: [CustomerDTO]) throws
    func addCustomer(customer: Customer) -> String
    func getCustomersList(seachText: String, order: CustomerOrder, filter: CustomerFilterAttributes, page: Int, pageSize: Int) -> [Customer]
    func getSalesDetailHistory(customer: Customer, page: Int, pageSize: Int) -> [SaleDetail]
    func updateCustomer(customer: Customer)
    func deleteCustomer(customer: Customer)
    func filterCustomer(word: String) -> [Customer]
    func setOrder(order: CustomerOrder)
    func setFilter(filter: CustomerFilterAttributes)
    func getCustomer(customer: Customer) -> Customer?
}

class LocalCustomerManagerImpl: LocalCustomerManager {
    //TODO: Delete these variables, should be only in ViewModel
    var customerOrder: CustomerOrder = .nameAsc
    var customerFilterAttributes: CustomerFilterAttributes = .allCustomers
    let sessionConfig: SessionConfig
    let mainContext: NSManagedObjectContext
    init(
        mainContext: NSManagedObjectContext,
        sessionConfig: SessionConfig
    ) {
        self.mainContext = mainContext
        self.sessionConfig = sessionConfig
    }
    func saveData() {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en LocalEmployeeManager: \(error)")
        }
    }
    func rollback() {
        self.mainContext.rollback()
    }
    func getLastUpdated() throws -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 1999, month: 1, day: 1)
        let dateFrom = calendar.date(from: components)
        let request: NSFetchRequest<Tb_Customer> = Tb_Customer.fetchRequest()
        let predicate = NSPredicate(format: "toCompany.idCompany == %@ AND updatedAt != nil", self.sessionConfig.companyId.uuidString)
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.fetchLimit = 1
        let listDate = try self.mainContext.fetch(request).map{$0.updatedAt}
        guard let last = listDate[0] else {
            print("Se retorna valor por defecto")
            return dateFrom
        }
        print("Se retorna valor desde la BD")
        return last
    }
    private func getCustomerById(customerId: UUID) -> Tb_Customer? {
        let request: NSFetchRequest<Tb_Customer> = Tb_Customer.fetchRequest()
        let predicate = NSPredicate(format: "toCompany.idCompany == %@", self.sessionConfig.companyId.uuidString)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try self.mainContext.fetch(request).first
            return result
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    //Sync
    func sync(customersDTOs: [CustomerDTO]) throws {
        for customerDTO in customersDTOs {
            guard self.sessionConfig.companyId == customerDTO.companyID else {
                throw LocalStorageError.notFound("La compañia no es la misma")
            }
            if let customerEntity = getCustomerById(customerId: customerDTO.id) {
                customerEntity.creditLimit = Int64(customerDTO.creditLimit)
                customerEntity.creditScore = Int64(customerDTO.creditScore)
                customerEntity.creditDays = Int64(customerDTO.creditDays)
                customerEntity.isCreditLimitActive = customerDTO.isCreditLimitActive
                customerEntity.isCreditLimit = customerDTO.isCreditLimit
                customerEntity.dateLimit = customerDTO.dateLimit
                customerEntity.isDateLimitActive = customerDTO.isDateLimitActive
                customerEntity.isDateLimit = customerDTO.isDateLimit
                customerEntity.lastName = customerDTO.lastName
                customerEntity.name = customerDTO.name
                customerEntity.phoneNumber = customerDTO.phoneNumber
                customerEntity.lastDatePurchase = customerDTO.lastDatePurchase
                customerEntity.firstDatePurchaseWithCredit = customerDTO.firstDatePurchaseWithCredit
                customerEntity.totalDebt = Int64(customerDTO.totalDebt)
                customerEntity.createdAt = customerDTO.createdAt.internetDateTime()
                customerEntity.updatedAt = customerDTO.updatedAt.internetDateTime()
            } else {
                let newCustomerEntity = Tb_Customer(context: self.mainContext)
                newCustomerEntity.idCustomer = customerDTO.id
                newCustomerEntity.creditLimit = Int64(customerDTO.creditLimit)
                newCustomerEntity.creditScore = Int64(customerDTO.creditScore)
                newCustomerEntity.creditDays = Int64(customerDTO.creditDays)
                newCustomerEntity.isCreditLimitActive = customerDTO.isCreditLimitActive
                newCustomerEntity.isCreditLimit = customerDTO.isCreditLimit
                newCustomerEntity.dateLimit = customerDTO.dateLimit
                newCustomerEntity.isDateLimitActive = customerDTO.isDateLimitActive
                newCustomerEntity.isDateLimit = customerDTO.isDateLimit
                newCustomerEntity.lastName = customerDTO.lastName
                newCustomerEntity.name = customerDTO.name
                newCustomerEntity.phoneNumber = customerDTO.phoneNumber
                newCustomerEntity.lastDatePurchase = customerDTO.lastDatePurchase
                newCustomerEntity.firstDatePurchaseWithCredit = customerDTO.firstDatePurchaseWithCredit
                newCustomerEntity.totalDebt = Int64(customerDTO.totalDebt)
                newCustomerEntity.createdAt = customerDTO.createdAt.internetDateTime()
                newCustomerEntity.updatedAt = customerDTO.updatedAt.internetDateTime()
            }
        }
        saveData()
    }
    //C - Create
    func addCustomer(customer: Customer) -> String {
        if let customerEntity = customer.toCustomerEntity(context: self.mainContext) { //Busqueda por id
            customerEntity.name = customer.name
            customerEntity.lastName = customer.lastName
            customerEntity.creditDays = Int64(customer.creditDays)
            //customerEntity.creditActive = customer.creditActive
            customerEntity.creditLimit = Int64(customer.creditLimit.cents)
            //print("BD isCreditLimitActive Before: \(customerEntity.isCreditLimitActive)")
            customerEntity.isCreditLimitActive = customer.isCreditLimitActive
            //print("BD isCreditLimitActive After: \(customerEntity.isCreditLimitActive)")
            customerEntity.isDateLimitActive = customer.isDateLimitActive
            customerEntity.phoneNumber = customer.phoneNumber
            if customer.isDateLimitActive && customerEntity.totalDebt > 0 && customerEntity.firstDatePurchaseWithCredit != nil {
                var calendar = Calendar.current
                calendar.timeZone = TimeZone(identifier: "UTC")!
                customerEntity.dateLimit = calendar.date(byAdding: .day, value: Int(customerEntity.creditDays), to: customerEntity.firstDatePurchaseWithCredit!)!
                //print("Se actualizo DateLimit en CustomerManager: \(String(describing: customerEntity.dateLimit?.description))")
                let finalDelDia = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
                customerEntity.isDateLimit = customerEntity.dateLimit ?? Date() < finalDelDia
                //print("finalDelDia en CustomerManager: \(String(describing: finalDelDia.description))")
                //print("creditDays en CustomerManager: \(String(describing: customerEntity.creditDays))")
                //print("firstDatePurchaseWithCredit en CustomerManager: \(String(describing: customerEntity.firstDatePurchaseWithCredit!.description))")
            }
            if let imageNN = customer.image {
                if let imageEntity = imageNN.toImageUrlEntity(context: self.mainContext) { //Comprobamos si la imagen o la URL existe para asignarle el mismo
                    customerEntity.toImageUrl = imageEntity
                } else {
                    let newImage = Tb_ImageUrl(context: self.mainContext)
                    newImage.idImageUrl = imageNN.id
                    newImage.imageUrl = imageNN.imageUrl
                    newImage.imageHash = imageNN.imageHash
                    print("Se guardo el hash: \(imageNN.imageHash)")
                    customerEntity.toImageUrl = newImage
                }
            }
            if customerEntity.isCreditLimitActive {
                print("Entro porque es true")
                customerEntity.isCreditLimit = customerEntity.totalDebt >= customerEntity.creditLimit
            } else {
                customerEntity.isCreditLimit = false
                print("Se apago el Flag")
            }
            saveData()
            return ""
        } else if customerExist(customer: customer) { //Comprobamos si existe el mismo empleado por otros atributos
            rollback()
            return "Hay otro cliente con el mismo nombre y apellido"
        } else { //Creamos un nuevo empleado
            let newCustomerEntity = Tb_Customer(context: self.mainContext)
            newCustomerEntity.idCustomer = customer.id
            newCustomerEntity.name = customer.name
            newCustomerEntity.lastName = customer.lastName
            newCustomerEntity.creditDays = Int64(customer.creditDays)
            if let imageNN = customer.image {
                if let imageEntity = imageNN.toImageUrlEntity(context: self.mainContext) { //Comprobamos si la imagen o la URL existe para asignarle el mismo
                    newCustomerEntity.toImageUrl = imageEntity
                } else {
                    let newImage = Tb_ImageUrl(context: self.mainContext)
                    newImage.idImageUrl = imageNN.id
                    newImage.imageUrl = imageNN.imageUrl
                    newImage.imageHash = imageNN.imageHash
                    newCustomerEntity.toImageUrl = newImage
                }
            }
            //newCustomerEntity.creditActive = customer.creditActive
            newCustomerEntity.creditLimit = Int64(customer.creditLimit.cents)
            newCustomerEntity.creditScore = 50
            newCustomerEntity.dateLimit = Date()
            newCustomerEntity.phoneNumber = customer.phoneNumber
            newCustomerEntity.totalDebt = 0
            newCustomerEntity.isDateLimitActive = customer.isDateLimitActive
            newCustomerEntity.isCreditLimitActive = customer.isCreditLimitActive
            newCustomerEntity.toCompany?.idCompany = self.sessionConfig.companyId
            saveData()
            return ""
        }
    }
    //R - Read
    func getCustomers() -> [Customer] {
        var customerEntityList: [Tb_Customer] = []
        let request: NSFetchRequest<Tb_Customer> = Tb_Customer.fetchRequest()
        do {
            customerEntityList = try self.mainContext.fetch(request)
        } catch let error {
            print("Error fetching. \(error)")
        }
        return customerEntityList.map { $0.toCustomer() }
    }
    func getCustomer(customer: Customer) -> Customer? {
        if let customerNN = customer.toCustomerEntity(context: self.mainContext) {
            return customerNN.toCustomer()
        } else {
            return nil
        }
    }
    func getCustomersList(seachText: String, order: CustomerOrder, filter: CustomerFilterAttributes, page: Int, pageSize: Int) -> [Customer] {
        var cutomerList: [Customer] = []
        let request: NSFetchRequest<Tb_Customer> = Tb_Customer.fetchRequest()
        request.fetchLimit = pageSize
        request.fetchOffset = (page - 1) * pageSize
        
        var predicate1 = NSPredicate(format: "toCompany.idCompany == %@", self.sessionConfig.companyId.uuidString)
        if seachText != "" {
            predicate1 = NSPredicate(format: "(name CONTAINS[c] %@ OR lastName CONTAINS[c] %@) AND toCompany.idCompany == %@", seachText, seachText, self.sessionConfig.companyId.uuidString)
        }
        let predicate2 = getFilter(filter: filter)
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicate1, predicate2])
        
        request.predicate = compoundPredicate
        let sortDescriptor = getOrder(order: order)
        request.sortDescriptors = [sortDescriptor]
        do {
            cutomerList = try self.mainContext.fetch(request).map{$0.toCustomer()}
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
        
        let predicate = NSPredicate(format: "toSale.toCustomer.toCompany.idCompany == %@ AND toSale.toCustomer.idCustomer == %@", self.sessionConfig.companyId.uuidString, customer.id.uuidString)
        request.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "toSale.saleDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        do {
            salesCutomerList = try self.mainContext.fetch(request).map{$0.toSaleDetail()}
        } catch let error {
            print("Error fetching. \(error)")
        }
        return salesCutomerList
    }
    func getFilter(filter: CustomerFilterAttributes) -> NSPredicate {
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
    func getOrder(order: CustomerOrder) -> NSSortDescriptor {
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
    //U - Update
    func updateCustomer(customer: Customer) {
        
    }
    //D - Delete
    func deleteCustomer(customer: Customer) {
        
    }
    func customerExist(customer: Customer) -> Bool {
        let filterAtt = NSPredicate(format: "name == %@ AND lastName == %@", customer.name, customer.lastName)
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
    func filterCustomer(word: String) -> [Customer] {
        var customers: [Customer] = []
        let fetchRequest: NSFetchRequest<Tb_Customer> = Tb_Customer.fetchRequest()
        let predicate1 = NSPredicate(format: "name CONTAINS[c] %@ AND toCompany.idCompany == %@", word, self.sessionConfig.companyId.uuidString)
        let predicate2 = getFilterAtribute()
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicate1, predicate2])
        fetchRequest.predicate = compoundPredicate
        // Agregar el sort descriptor para ordenar por nombre ascendente
        let sortDescriptor = getOrderFilter()
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            // Ejecutar la consulta y obtener los resultados
            let customersBD = try self.mainContext.fetch(fetchRequest)
            customers = customersBD.map{$0.toCustomer()}
            return customers
        } catch {
            print("Error al ejecutar la consulta: \(error.localizedDescription)")
            return customers
        }
    }
    func getOrderFilter() -> NSSortDescriptor {
        var sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        switch customerOrder {
        case .nameAsc:
            sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        case .nextDate:
            sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        case .quantityAsc:
            sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        case .quantityDesc:
            sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        }
        return sortDescriptor
    }
    func getFilterAtribute() -> NSPredicate {
        var filterAtt = NSPredicate(format: "active == true")
        switch customerFilterAttributes {
        case .allCustomers:
            filterAtt = NSPredicate(format: "active == true")
        case .dueByDate:
            filterAtt = NSPredicate(format: "active == true")
        case .excessAmount:
            filterAtt = NSPredicate(format: "active == true")
        case .onTime:
            filterAtt = NSPredicate(format: "active == true")
        }
        return filterAtt
    }
    func setOrder(order: CustomerOrder) {
        self.customerOrder = order
    }
    func setFilter(filter: CustomerFilterAttributes) {
        self.customerFilterAttributes = filter
    }
}
