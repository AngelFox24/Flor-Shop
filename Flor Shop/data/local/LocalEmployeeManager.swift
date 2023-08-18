//
//  LocalEmployeeManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol EmployeeManager {
    func addEmployee(employee: Employee)
    func getEmployee(id: UUID) -> Employee
    func updateEmployee(employee: Employee)
    func deleteEmployee(employee: Employee)
}

class LocalEmployeeManager: EmployeeManager {
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
    func addEmployee(employee: Employee) {
        
    }
    //R - Read
    func getEmployee(id: UUID) -> Employee {
        return Employee(id: id, name: "Angel", lastName: "Curi Laurente", role: "Vendedor", image: ImageUrl(id: id, imageUrl: "https://media.licdn.com/dms/image/D4E03AQGi8lmT8Kk_sQ/profile-displayphoto-shrink_800_800/0/1689080795681?e=2147483647&v=beta&t=2C0ItSYPqY2jrq6UKMBuuDObrYl5nQ-LNp-9VUqUNa0"), active: true)
    }
    //U - Update
    func updateEmployee(employee: Employee) {
        
    }
    //D - Delete
    func deleteEmployee(employee: Employee) {
        
    }
}

