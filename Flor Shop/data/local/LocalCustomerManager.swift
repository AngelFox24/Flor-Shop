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
    func getCustomer(id: UUID) -> Customer
    func updateCustomer(customer: Customer)
    func deleteCustomer(customer: Customer)
}

class LocalCustomerManager: CustomerManager {
    let mainContext: NSManagedObjectContext
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
    func getCustomer(id: UUID) -> Customer {
        return Customer(id: id, name: "Cindy", lastName: "Jarpi Menestra", image: ImageUrl(id: id, imageUrl: "https://yt3.googleusercontent.com/ytc/AOPolaRY4C6rIYTttVCU1PvNZis2qljWBq7Y46D9TG1TpA=s900-c-k-c0x00ffffff-no-rj"), active: true, creditLimit: 2000.0)
    }
    //U - Update
    func updateCustomer(customer: Customer) {
        
    }
    //D - Delete
    func deleteCustomer(customer: Customer) {
        
    }
}
