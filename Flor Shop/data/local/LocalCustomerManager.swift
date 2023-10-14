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
    func getCustomers() -> [Customer]
    func updateCustomer(customer: Customer)
    func deleteCustomer(customer: Customer)
    func filterCustomer(word: String) -> [Customer]
    func setOrder(order: CustomerOrder)
    func setFilter(filter: CustomerFilterAttributes)
    func setDefaultCompany(company: Company)
    func getDefaultCompany() -> Company?
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
            print("Error al guardar en LocalEmployeeManager: \(error)")
        }
    }
    func rollback() {
        self.mainContext.rollback()
    }
    //C - Create
    func addCustomer(customer: Customer) -> String {
        guard let companyEntity = self.mainCompanyEntity else {
            return "La hay compañia default"
        }
        if customer.toCustomerEntity(context: self.mainContext) != nil { //Busqueda por id
            rollback()
            return "Cliente ya existe: \(String(describing: customer.name))"
        } else if customerExist(customer: customer) { //Comprobamos si existe el mismo empleado por otros atributos
            rollback()
            return "Hay otro cliente con el mismo nombre y apellido"
        } else { //Creamos un nuevo empleado
            let newCustomerEntity = Tb_Customer(context: self.mainContext)
            newCustomerEntity.idCustomer = customer.id
            newCustomerEntity.name = customer.name
            newCustomerEntity.lastName = customer.lastName
            if let imageEntity = customer.image.toImageUrlEntity(context: self.mainContext) { //Comprobamos si la imagen o la URL existe para asignarle el mismo
                newCustomerEntity.toImageUrl = imageEntity
            } else { // Si no existe creamos uno nuevo
                let newImage = Tb_ImageUrl(context: self.mainContext)
                newImage.idImageUrl = customer.image.id
                newImage.imageUrl = customer.image.imageUrl
                newCustomerEntity.toImageUrl = newImage
            }
            newCustomerEntity.active = customer.active
            newCustomerEntity.creditLimit = customer.creditLimit ?? 0
            newCustomerEntity.dateLimit = customer.dateLimit
            newCustomerEntity.phoneNumber = customer.phoneNumber
            newCustomerEntity.totalDebt = 0
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
