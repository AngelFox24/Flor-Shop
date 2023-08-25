//
//  LocalEmployeeManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol EmployeeManager {
    func addEmployee(employee: Employee) -> Bool
    func getEmployees() -> [Employee]
    func getEmployee() -> Employee?
    func updateEmployee(employee: Employee)
    func deleteEmployee(employee: Employee)
    func logIn(user: String, password: String) -> Employee?
    func setDefaultEmployee(employee: Employee)
    func getEmployeeSubsidiary() -> Subsidiary?
}

class LocalEmployeeManager: EmployeeManager {
    let mainContext: NSManagedObjectContext
    var mainEmployeeEntity: Tb_Employee?
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
    func setDefaultEmployee(employee: Employee) {
        guard let employeeEntity = employee.toEmployeeEntity(context: self.mainContext) else {
            print("No se pudo asingar empleado default")
            return
        }
        self.mainEmployeeEntity = employeeEntity
    }
    //C - Create
    func addEmployee(employee: Employee) -> Bool {
        guard let employeeEntity = employee.toEmployeeEntity(context: mainContext) else {
            let newEmployeeEntity = Tb_Employee(context: self.mainContext)
            newEmployeeEntity.idEmployee = employee.id
            newEmployeeEntity.name = employee.name
            newEmployeeEntity.lastName = employee.lastName
            newEmployeeEntity.role = employee.role
            newEmployeeEntity.active = employee.active
            newEmployeeEntity.toSubsidiary = mainEmployeeEntity?.toSubsidiary
            if let imageEntity = employee.image.toImageUrlEntity(context: self.mainContext) {
                newEmployeeEntity.toImageUrl = imageEntity
            } else {
                let newImage = Tb_ImageUrl(context: self.mainContext)
                newImage.idImageUrl = UUID()
                newImage.imageUrl = employee.image.imageUrl
                newEmployeeEntity.toImageUrl = newImage
            }
            saveData()
            return true
        }
        rollback()
        return false
    }
    //R - Read
    func getEmployees() -> [Employee] {
        var employeesEntityList: [Tb_Employee] = []
        let request: NSFetchRequest<Tb_Employee> = Tb_Employee.fetchRequest()
        do {
            employeesEntityList = try self.mainContext.fetch(request)
        } catch let error {
            print("Error fetching. \(error)")
        }
        return employeesEntityList.map { $0.toEmployee() }
    }
    func getEmployee() -> Employee? {
        return mainEmployeeEntity?.toEmployee()
    }
    func getEmployeeSubsidiary() -> Subsidiary? {
        return mainEmployeeEntity?.toSubsidiary?.toSubsidiary()
    }
    //U - Update
    func updateEmployee(employee: Employee) {
        
    }
    //D - Delete
    func deleteEmployee(employee: Employee) {
        
    }
    func logIn(user: String, password: String) -> Employee? {
        var employeeEntity: Tb_Employee?
        let request: NSFetchRequest<Tb_Employee> = Tb_Employee.fetchRequest()
        let filterAtt = NSPredicate(format: "user == %@", user)
        request.predicate = filterAtt
        do {
            employeeEntity = try self.mainContext.fetch(request).first
        } catch let error {
            print("Error fetching. \(error)")
        }
        if let employee = employeeEntity {
            //setDefaultEmployee(employee: employee.toEmployee())
            return employee.toEmployee()
        } else {
            return nil
        }
    }
}

