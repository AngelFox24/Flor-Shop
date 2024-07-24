//
//  SessionConfig.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 15/07/2024.
//

import Foundation
import CoreData

struct SessionConfig {
    let companyId: UUID
    let subsidiaryId: UUID
    let employeeId: UUID
    
    func getCompanyEntity(context: NSManagedObjectContext) throws -> Tb_Company {
        let request: NSFetchRequest<Tb_Company> = Tb_Company.fetchRequest()
        let predicate = NSPredicate(format: "idCompany == %@", companyId.uuidString)
        request.predicate = predicate
        request.fetchLimit = 1
        guard let result = try context.fetch(request).first else {
            throw LocalStorageError.notFound("No se encontro esta compañia en Local Storage")
        }
        return result
    }
    func getSubsidiaryEntity(context: NSManagedObjectContext) throws -> Tb_Subsidiary {
        let request: NSFetchRequest<Tb_Subsidiary> = Tb_Subsidiary.fetchRequest()
        let predicate = NSPredicate(format: "idSubsidiary == %@", subsidiaryId.uuidString)
        request.predicate = predicate
        request.fetchLimit = 1
        guard let result = try context.fetch(request).first else {
            throw LocalStorageError.notFound("No se encontro esta subsidiaria en Local Storage")
        }
        return result
    }
    func getEmployeeEntity(context: NSManagedObjectContext) throws -> Tb_Employee {
        let request: NSFetchRequest<Tb_Employee> = Tb_Employee.fetchRequest()
        let predicate = NSPredicate(format: "idEmployee == %@", employeeId.uuidString)
        request.predicate = predicate
        request.fetchLimit = 1
        guard let result = try context.fetch(request).first else {
            throw LocalStorageError.notFound("No se encontro este empleado en Local Storage")
        }
        return result
    }
}
