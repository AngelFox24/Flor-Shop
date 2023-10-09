//
//  LocalCustomerManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol CustomerManager {
    func addCustomer(customer: Customer)
    func getCustomers() -> [Customer]
    func updateCustomer(customer: Customer)
    func deleteCustomer(customer: Customer)
}

class LocalCustomerManager: CustomerManager {
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
    func addCustomer(customer: Customer) {
        
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
}
