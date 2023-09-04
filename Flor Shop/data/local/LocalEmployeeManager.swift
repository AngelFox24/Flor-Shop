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
    func updateEmployee(employee: Employee)
    func deleteEmployee(employee: Employee)
    func logIn(user: String, password: String) -> Employee?
    func setDefaultSubsidiary(employee: Employee)
    func setDefaultSubsidiary(subisidiary: Subsidiary)
    func getEmployeeSubsidiary() -> Subsidiary?
    func getSubsidiary(employee: Employee) -> Subsidiary?
    func getDefaultSubsidiary() -> Subsidiary?
}

class LocalEmployeeManager: EmployeeManager {
    let mainContext: NSManagedObjectContext
    var mainSubsidiaryEntity: Tb_Subsidiary?
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
    func setDefaultSubsidiary(employee: Employee) {
        guard let employeeEntity = employee.toEmployeeEntity(context: mainContext), let subsidiaryEntity: Tb_Subsidiary = employeeEntity.toSubsidiary else {
            print("No se pudo asingar sucursar default")
            return
        }
        self.mainSubsidiaryEntity = subsidiaryEntity
    }
    func setDefaultSubsidiary(subisidiary: Subsidiary) {
        guard let subsidiaryEntity: Tb_Subsidiary = subisidiary.toSubsidiaryEntity(context: self.mainContext) else {
            print("No se pudo asingar sucursar default")
            return
        }
        self.mainSubsidiaryEntity = subsidiaryEntity
    }
    func getDefaultSubsidiary() -> Subsidiary? {
        return self.mainSubsidiaryEntity?.toSubsidiary()
    }
    //C - Create
    func addEmployee(employee: Employee) -> Bool {
        guard let employeeEntity = employee.toEmployeeEntity(context: mainContext) else {
            let newEmployeeEntity = Tb_Employee(context: self.mainContext)
            newEmployeeEntity.idEmployee = employee.id
            newEmployeeEntity.email = employee.email
            newEmployeeEntity.name = employee.name
            newEmployeeEntity.lastName = employee.lastName
            newEmployeeEntity.role = employee.role
            newEmployeeEntity.active = employee.active
            newEmployeeEntity.toSubsidiary = self.mainSubsidiaryEntity
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
        print("Empleado ya existe: \(employeeEntity.name)")
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
    func getEmployeeSubsidiary() -> Subsidiary? {
        return self.mainSubsidiaryEntity?.toSubsidiary()
    }
    func getSubsidiary(employee: Employee) -> Subsidiary? {
        guard let subsidiaryEntity = employee.toEmployeeEntity(context: self.mainContext)?.toSubsidiary else {
            print("No se pudo obtener la sucursal del empleado")
            return nil
        }
        return subsidiaryEntity.toSubsidiary()
    }
    //U - Update
    func updateEmployee(employee: Employee) {
        
    }
    //D - Delete
    func deleteEmployee(employee: Employee) {
        
    }
    func logIn(user: String, password: String) -> Employee? {
        let request: NSFetchRequest<Tb_Employee> = Tb_Employee.fetchRequest()
        print("Se intenta buscar en BD al empleado \(user)")
        let filterAtt = NSPredicate(format: "email == %@", user)
        request.predicate = filterAtt
        do {
            let employeeList = try self.mainContext.fetch(request)
            print("Contamos los empleados \(employeeList.count)")
            for employee in employeeList {
                print("nombre: \(String(describing: employee.name)) email: \(String(describing: employee.email))")
            }
            return employeeList.first?.toEmployee()
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
}

