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
    func getCustomer(id: UUID) -> Employee
    func updateCustomer(customer: Customer)
    func deleteCustomer(customer: Customer)
}

class LocalCustomerManager: CustomerManager {
    let mainContext: NSManagedObjectContext
    func saveData() {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en LocalEmployeeManager: \(error)")
        }
    }
    func rollback() {
        do {
            try self.mainContext.rollback()
        } catch {
            print("Error al hacer rollback en LocalEmployeeManager: \(error)")
        }
    }
    //C - Create
    func addCustomer(customer: Customer) {
        
    }
    //R - Read
    func getCustomer(id: UUID) -> Employee {
        return Customer(idCustomer: id, name: "Cindy", lastName: "Jarpi Menestra", image: ImageUrl(idImageUrl: id, mageUrl: "https://yt3.googleusercontent.com/ytc/AOPolaRY4C6rIYTttVCU1PvNZis2qljWBq7Y46D9TG1TpA=s900-c-k-c0x00ffffff-no-rj"), active: true, creditLimit: 2000.0)
    }
    //U - Update
    func updateCustomer(customer: Customer) {
        
    }
    //D - Delete
    func deleteCustomer(customer: Customer) {
        
    }
}
