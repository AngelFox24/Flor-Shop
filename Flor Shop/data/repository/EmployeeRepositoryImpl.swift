//
//  EmployeeRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol EmployeeRepository {
    func addEmployee(employee: Employee)
    func getEmployee(id: UUID) -> Employee
    func updateEmployee(employee: Employee)
    func deleteEmployee(employee: Employee)
}

class EmployeeRepositoryImpl: EmployeeRepository {
    let manager: EmployeeManager
    // let remote:  remoto, se puede implementar el remoto aqui
    init(manager: EmployeeManager) {
        self.manager = manager
    }
    //C - Create
    func addEmployee(employee: Employee) {
        self.manager.addEmployee(employee: employee)
    }
    //R - Read
    func getEmployee(id: UUID) -> Employee {
        return self.manager.getEmployee(id: id)
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
