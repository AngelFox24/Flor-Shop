//
//  LocalCustomerManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol CustomerManager {
    func addCustomer(customer: Customer) -> String
    func getCustomersList(seachText: String, order: CustomerOrder, filter: CustomerFilterAttributes, page: Int, pageSize: Int) -> [Customer]
    func getSalesDetailHistory(customer: Customer, page: Int, pageSize: Int) -> [SaleDetail]
    func updateCustomer(customer: Customer)
    func deleteCustomer(customer: Customer)
    func filterCustomer(word: String) -> [Customer]
    func setOrder(order: CustomerOrder)
    func setFilter(filter: CustomerFilterAttributes)
    func setDefaultCompany(company: Company)
    func getDefaultCompany() -> Company?
    func getCustomer(customer: Customer) -> Customer?
    func releaseResourses()
}

class LocalCustomerManager: CustomerManager {
    var customerOrder: CustomerOrder = .nameAsc
    var customerFilterAttributes: CustomerFilterAttributes = .allCustomers
    let mainContext: NSManagedObjectContext
    var mainCompanyEntity: Tb_Company?
    init(mainContext: NSManagedObjectContext) {
        self.mainContext = mainContext
    }
    func saveData() {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en LocalCustomerManager: \(error)")
        }
    }
    func rollback() {
        self.mainContext.rollback()
    }
    func releaseResourses() {
        self.mainCompanyEntity = nil
    }
    //C - Create
    func addCustomer(customer: Customer) -> String {
        guard let companyEntity = self.mainCompanyEntity else {
            return "La hay compañia default"
        }
        if let customerEntity = customer.toCustomerEntity(context: self.mainContext) { //Busqueda por id
            customerEntity.name = customer.name
            customerEntity.lastName = customer.lastName
            customerEntity.creditDays = Int64(customer.creditDays)
            //customerEntity.creditActive = customer.creditActive
            customerEntity.creditLimit = customer.creditLimit
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
            if let imageEntity = customer.image.toImageUrlEntity(context: self.mainContext) { //Comprobamos si la imagen o la URL existe para asignarle el mismo
                newCustomerEntity.toImageUrl = imageEntity
            } else { // Si no existe creamos uno nuevo
                let newImage = Tb_ImageUrl(context: self.mainContext)
                newImage.idImageUrl = customer.image.id
                newImage.imageUrl = customer.image.imageUrl
                newCustomerEntity.toImageUrl = newImage
            }
            //newCustomerEntity.creditActive = customer.creditActive
            newCustomerEntity.creditLimit = customer.creditLimit
            newCustomerEntity.creditScore = 50
            newCustomerEntity.dateLimit = Date()
            newCustomerEntity.phoneNumber = customer.phoneNumber
            newCustomerEntity.totalDebt = 0
            newCustomerEntity.isDateLimitActive = customer.isDateLimitActive
            newCustomerEntity.isCreditLimitActive = customer.isCreditLimitActive
            newCustomerEntity.toCompany = companyEntity
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
        guard let companyEntity = self.mainCompanyEntity else {
            print("No se encontró compañia")
            return cutomerList
        }
        let request: NSFetchRequest<Tb_Customer> = Tb_Customer.fetchRequest()
        request.fetchLimit = pageSize
        request.fetchOffset = (page - 1) * pageSize
        
        var predicate1 = NSPredicate(format: "toCompany == %@", companyEntity)
        if seachText != "" {
            predicate1 = NSPredicate(format: "(name CONTAINS[c] %@ OR lastName CONTAINS[c] %@) AND toCompany == %@", seachText, seachText, companyEntity)
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
        guard let companyEntity = self.mainCompanyEntity else {
            print("No se encontró compañia")
            return salesCutomerList
        }
        guard let customerEntity = customer.toCustomerEntity(context: self.mainContext) else {
            print("No se encontró cliente")
            return salesCutomerList
        }
        let request: NSFetchRequest<Tb_SaleDetail> = Tb_SaleDetail.fetchRequest()
        request.fetchLimit = pageSize
        request.fetchOffset = (page - 1) * pageSize
        
        let predicate = NSPredicate(format: "toSale.toCustomer.toCompany == %@ AND toSale.toCustomer == %@", companyEntity, customerEntity)
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
    func setDefaultCompany(company: Company) {
        guard let companyEntity = company.toCompanyEntity(context: self.mainContext) else {
            print("No se pudo asingar sucursar default")
            return
        }
        self.mainCompanyEntity = companyEntity
    }
    func getDefaultCompany() -> Company? {
        return self.mainCompanyEntity?.toCompany()
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
        guard let companyEntity: Tb_Company = self.mainCompanyEntity else {
            print("No se encontró compañia")
            return customers
        }
        let fetchRequest: NSFetchRequest<Tb_Customer> = Tb_Customer.fetchRequest()
        let predicate1 = NSPredicate(format: "name CONTAINS[c] %@ AND toCompany == %@", word, companyEntity)
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
