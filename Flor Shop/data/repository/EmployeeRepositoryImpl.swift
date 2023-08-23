//
//  EmployeeRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol EmployeeRepository {
    func addEmployee(subsidiary: Subsidiary, employee: Employee) -> Bool
    func getEmployees() -> [Employee]
    func updateEmployee(employee: Employee)
    func deleteEmployee(employee: Employee)
    func logIn(user: String, password: String) -> Employee?
}

class EmployeeRepositoryImpl: EmployeeRepository {
    let manager: EmployeeManager
    // let remote:  remoto, se puede implementar el remoto aqui
    init(manager: EmployeeManager) {
        self.manager = manager
    }
    //Luego se migrara a Firebase
    func logIn(user: String, password: String) -> Employee? {
        return self.manager.logIn(user: user, password: password)
    }
    //C - Create
    func addEmployee(subsidiary: Subsidiary, employee: Employee) -> Bool {
        return self.manager.addEmployee(subsidiary: subsidiary, employee: employee)
    }
    //R - Read
    func getEmployees() -> [Employee] {
        return self.manager.getEmployees()
    }
    //U - Update
    func updateEmployee(employee: Employee) {
        self.manager.updateEmployee(employee: employee)
    }
    //D - Delete
    func deleteEmployee(employee: Employee) {
        self.manager.deleteEmployee(employee: employee)
    }
}
