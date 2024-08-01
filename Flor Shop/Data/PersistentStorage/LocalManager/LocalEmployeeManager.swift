//
//  LocalEmployeeManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol LocalEmployeeManager {
    func sync(employeesDTOs: [EmployeeDTO]) throws
    func getLastUpdated() -> Date
    func save(employee: Employee)
    func getEmployees() -> [Employee]
}

class LocalEmployeeManagerImpl: LocalEmployeeManager {
    let sessionConfig: SessionConfig
    let mainContext: NSManagedObjectContext
    init(
        mainContext: NSManagedObjectContext,
        sessionConfig: SessionConfig
    ) {
        self.mainContext = mainContext
        self.sessionConfig = sessionConfig
    }
    func getLastUpdated() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 1999, month: 1, day: 1)
        let dateFrom = calendar.date(from: components)
        let request: NSFetchRequest<Tb_Employee> = Tb_Employee.fetchRequest()
        let predicate = NSPredicate(format: "toSubsidiary.idSubsidiary == %@ AND updatedAt != nil", self.sessionConfig.subsidiaryId.uuidString)
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let date = try self.mainContext.fetch(request).compactMap{$0.updatedAt}.first
            guard let dateNN = date else {
                return dateFrom!
            }
            return dateNN
        } catch let error {
            print("Error fetching. \(error)")
            return dateFrom!
        }
    }
    func sync(employeesDTOs: [EmployeeDTO]) throws {
        for employeeDTO in employeesDTOs {
            guard self.sessionConfig.subsidiaryId == employeeDTO.subsidiaryID else {
                throw LocalStorageError.notFound("La subsidiaria no es la misma")
            }
            if let employeeEntity = self.sessionConfig.getEmployeeEntityById(context: self.mainContext, employeeId: employeeDTO.id) {
                employeeEntity.name = employeeDTO.name
                employeeEntity.lastName = employeeDTO.lastName
                employeeEntity.active = employeeDTO.active
                employeeEntity.email = employeeDTO.email
                employeeEntity.phoneNumber = employeeDTO.phoneNumber
                employeeEntity.role = employeeDTO.role
                employeeEntity.user = employeeDTO.user
                employeeEntity.createdAt = employeeDTO.createdAt.internetDateTime()
                employeeEntity.updatedAt = employeeDTO.updatedAt.internetDateTime()
            } else {
                let newEmployeeEntity = Tb_Employee(context: self.mainContext)
                newEmployeeEntity.idEmployee = employeeDTO.id
                newEmployeeEntity.name = employeeDTO.name
                newEmployeeEntity.lastName = employeeDTO.lastName
                newEmployeeEntity.active = employeeDTO.active
                newEmployeeEntity.email = employeeDTO.email
                newEmployeeEntity.phoneNumber = employeeDTO.phoneNumber
                newEmployeeEntity.role = employeeDTO.role
                newEmployeeEntity.user = employeeDTO.user
                newEmployeeEntity.createdAt = employeeDTO.createdAt.internetDateTime()
                newEmployeeEntity.updatedAt = employeeDTO.updatedAt.internetDateTime()
            }
        }
        saveData()
    }
    func save(employee: Employee) {
        if let employeeEntity = self.sessionConfig.getEmployeeEntityById(context: self.mainContext, employeeId: employee.id) { //Busqueda por id
            employeeEntity.name = employee.name
            employeeEntity.lastName = employee.lastName
            employeeEntity.active = employee.active
            employeeEntity.email = employee.email
            employeeEntity.phoneNumber = employee.phoneNumber
            employeeEntity.role = employee.role
            employeeEntity.user = employee.user
            employeeEntity.toImageUrl?.idImageUrl = employee.image?.id
            employeeEntity.updatedAt = Date()
            saveData()
        } else if employeeExist(employee: employee) { //Comprobamos si existe el mismo empleado por otros atributos
            rollback()
        } else { //Creamos un nuevo empleado
            let newEmployeeEntity = Tb_Employee(context: self.mainContext)
            newEmployeeEntity.idEmployee = employee.id
            newEmployeeEntity.email = employee.email
            newEmployeeEntity.name = employee.name
            newEmployeeEntity.lastName = employee.lastName
            newEmployeeEntity.role = employee.role
            newEmployeeEntity.active = employee.active
            newEmployeeEntity.toSubsidiary?.idSubsidiary = self.sessionConfig.subsidiaryId
            newEmployeeEntity.toImageUrl?.idImageUrl = employee.image?.id
            saveData()
        }
    }
    func getEmployees() -> [Employee] {
        let filterAtt = NSPredicate(format: "toSubsidiary.idSubsidiary == %@", self.sessionConfig.subsidiaryId.uuidString)
        let request: NSFetchRequest<Tb_Employee> = Tb_Employee.fetchRequest()
        request.predicate = filterAtt
        do {
            let result = try self.mainContext.fetch(request)
            return result.compactMap {$0.toEmployee()}
        } catch let error {
            print("Error fetching. \(error)")
            return []
        }
    }
    func employeeExist(employee: Employee) -> Bool {
        let filterAtt = NSPredicate(format: "(name == %@ AND lastName == %@) OR email == %@", employee.name, employee.lastName, employee.email)
        let request: NSFetchRequest<Tb_Employee> = Tb_Employee.fetchRequest()
        request.predicate = filterAtt
        do {
            let total = try self.mainContext.fetch(request).count
            return total == 0 ? false : true
        } catch let error {
            print("Error fetching. \(error)")
            return false
        }
    }
    //MARK: Private Funtions
    private func saveData() {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en LocalEmployeeManager: \(error)")
            rollback()
        }
    }
    private func rollback() {
        self.mainContext.rollback()
    }
}

