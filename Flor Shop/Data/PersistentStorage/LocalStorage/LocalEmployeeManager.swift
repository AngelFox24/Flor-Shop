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
    func getLastUpdated() throws -> Date?
    func addEmployee(employee: Employee)
    func getEmployees() -> [Employee]
    func logIn(user: String, password: String) -> Employee?
    func getSessionSubsidiary() throws -> Subsidiary
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
    func getLastUpdated() throws -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 1999, month: 1, day: 1)
        let dateFrom = calendar.date(from: components)
        let request: NSFetchRequest<Tb_Employee> = Tb_Employee.fetchRequest()
        let predicate = NSPredicate(format: "toSubsidiary.idSubsidiary == %@ AND updatedAt != nil", self.sessionConfig.subsidiaryId.uuidString)
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.fetchLimit = 1
        let listDate = try self.mainContext.fetch(request).map{$0.updatedAt}
        guard let last = listDate[0] else {
            print("Se retorna valor por defecto")
            return dateFrom
        }
        print("Se retorna valor desde la BD")
        return last
    }
    private func getEmployeeById(employeeId: UUID) -> Tb_Employee? {
        let request: NSFetchRequest<Tb_Employee> = Tb_Employee.fetchRequest()
        let predicate = NSPredicate(format: "toSubsidiary.idSubsidiary == %@", self.sessionConfig.subsidiaryId.uuidString)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try self.mainContext.fetch(request).first
            return result
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    //Sync
    func sync(employeesDTOs: [EmployeeDTO]) throws {
        for employeeDTO in employeesDTOs {
            guard self.sessionConfig.subsidiaryId == employeeDTO.subsidiaryID else {
                throw LocalStorageError.notFound("La subsidiaria no es la misma")
            }
            if let employeeEntity = getEmployeeById(employeeId: employeeDTO.id) {
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
    func getSessionSubsidiary() throws -> Subsidiary {
        let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntity(context: self.mainContext)
        return subsidiaryEntity.toSubsidiary()
    }
    //C - Create
    func addEmployee(employee: Employee) {
        //TODO: Refactor this
        if employee.toEmployeeEntity(context: mainContext) != nil { //Busqueda por id
            print("Empleado ya existe: \(String(describing: employee.name))")
            rollback()
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
            if let imageEntity = employee.image?.toImageUrlEntity(context: self.mainContext) { //Comprobamos si la imagen o la URL existe para asignarle el mismo
                newEmployeeEntity.toImageUrl = imageEntity
            } else { // Si no existe creamos uno nuevo
                if let imageCl = employee.image {
                    let newImage = Tb_ImageUrl(context: self.mainContext)
                    newImage.idImageUrl = imageCl.id
                    newImage.imageUrl = imageCl.imageUrl
                    newEmployeeEntity.toImageUrl = newImage
                }
            }
            saveData()
        }
    }
    //R - Read
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
}

