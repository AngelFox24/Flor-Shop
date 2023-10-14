//
//  CustomerRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol CustomerRepository {
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

class CustomerRepositoryImpl: CustomerRepository {
    let manager: CustomerManager
    // let remote:  remoto, se puede implementar el remoto aqui
    init(manager: CustomerManager) {
        self.manager = manager
    }
    //C - Create
    func addCustomer(customer: Customer) -> String {
        return self.manager.addCustomer(customer: customer)
    }
    //R - Read
    func getCustomers() -> [Customer] {
        return self.manager.getCustomers()
    }
    //U - Update
    func updateCustomer(customer: Customer) {
        self.manager.updateCustomer(customer: customer)
    }
    //D - Delete
    func deleteCustomer(customer: Customer) {
        self.manager.deleteCustomer(customer: customer)
    }
    func filterCustomer(word: String) -> [Customer] {
        return self.manager.filterCustomer(word: word)
    }
    func setOrder(order: CustomerOrder) {
        self.manager.setOrder(order: order)
    }
    func setFilter(filter: CustomerFilterAttributes) {
        self.manager.setFilter(filter: filter)
    }
    func setDefaultCompany(company: Company) {
        self.manager.setDefaultCompany(company: company)
    }
    func getDefaultCompany() -> Company? {
        return self.manager.getDefaultCompany()
    }
}
