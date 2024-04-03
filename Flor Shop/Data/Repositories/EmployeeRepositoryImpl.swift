//
//  EmployeeRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol EmployeeRepository {
    func addEmployee(employee: Employee) -> Bool
    func getEmployees() -> [Employee]
    func updateEmployee(employee: Employee)
    func deleteEmployee(employee: Employee)
    func logIn(user: String, password: String) -> Employee?
    func setDefaultSubsidiary(employee: Employee)
    func getEmployeeSubsidiary() -> Subsidiary?
    func setDefaultSubsidiary(subsidiary: Subsidiary)
    func getSubsidiary(employee: Employee) -> Subsidiary?
    func getDefaultSubsidiary() -> Subsidiary?
    func releaseResourses()
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
    func addEmployee(employee: Employee) -> Bool {
        return self.manager.addEmployee(employee: employee)
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
    func setDefaultSubsidiary(employee: Employee) {
        self.manager.setDefaultSubsidiary(employee: employee)
    }
    func setDefaultSubsidiary(subsidiary: Subsidiary) {
        self.manager.setDefaultSubsidiary(subsidiary: subsidiary)
    }
    func getEmployeeSubsidiary() -> Subsidiary? {
        return self.manager.getEmployeeSubsidiary()
    }
    func getSubsidiary(employee: Employee) -> Subsidiary? {
        return self.manager.getSubsidiary(employee: employee)
    }
    func getDefaultSubsidiary() -> Subsidiary? {
        return self.manager.getDefaultSubsidiary()
    }
    func releaseResourses() {
        self.manager.releaseResourses()
    }
}
