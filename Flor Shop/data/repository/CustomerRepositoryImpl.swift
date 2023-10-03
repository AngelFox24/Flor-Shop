//
//  CustomerRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol CustomerRepository {
    func addCustomer(customer: Customer)
    func getCustomers() -> [Customer]
    func updateCustomer(customer: Customer)
    func deleteCustomer(customer: Customer)
}

class CustomerRepositoryImpl: CustomerRepository {
    let manager: CustomerManager
    // let remote:  remoto, se puede implementar el remoto aqui
    init(manager: CustomerManager) {
        self.manager = manager
    }
    //C - Create
    func addCustomer(customer: Customer) {
        self.manager.addCustomer(customer: customer)
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
}
