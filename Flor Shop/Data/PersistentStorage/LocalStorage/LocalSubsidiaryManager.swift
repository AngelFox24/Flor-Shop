//
//  LocalSubsidiaryManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol SubsidiaryManager {
    func addSubsidiary(subsidiary: Subsidiary) -> Bool
    func getSubsidiaries() -> [Subsidiary]
    func updateSubsidiary(subsidiary: Subsidiary)
    func deleteSubsidiary(subsidiary: Subsidiary)
    func setDefaultCompany(company: Company)
    func setDefaultSubsidiaryCompany(employee: Employee)
    func getCompany(subsidiary: Subsidiary) -> Company?
    func getDefaultCompany() -> Company?
    func releaseResourses()
}

class LocalSubsidiaryManager: SubsidiaryManager {
    let mainContext: NSManagedObjectContext
    var mainCompanyEntity: Tb_Company?
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
    func addSubsidiary(subsidiary: Subsidiary) -> Bool {
        guard let companyEntity = mainCompanyEntity else {
            print("No existe compañia para crear una sucursal")
            rollback()
            return false
        }
        if let _ = subsidiary.toSubsidiaryEntity(context: self.mainContext) {
            print("Ya existe sucursal, no se puede crear")
            rollback()
            return false
        } else {
            let newSubsidiaryEntity = Tb_Subsidiary(context: self.mainContext)
            newSubsidiaryEntity.idSubsidiary = subsidiary.id
            newSubsidiaryEntity.name = subsidiary.name
            newSubsidiaryEntity.toImageUrl = subsidiary.image?.toImageUrlEntity(context: self.mainContext)
            newSubsidiaryEntity.toCompany = companyEntity
            saveData()
            return true
        }
    }
    func releaseResourses() {
        self.mainCompanyEntity = nil
    }
    //R - Read
    func getSubsidiaries() -> [Subsidiary] {
        var subsidiaries: [Tb_Subsidiary] = []
        if let list = mainCompanyEntity?.toSubsidiary {
            subsidiaries = list.compactMap{$0 as? Tb_Subsidiary}
        }
        return subsidiaries.map{$0.toSubsidiary()}
    }
    func getCompany(subsidiary: Subsidiary) -> Company? {
        guard let companyEntity = subsidiary.toSubsidiaryEntity(context: self.mainContext)?.toCompany else {
            print("No se encontro la compañia de la sucursal")
            return nil
        }
        return companyEntity.toCompany()
    }
    //U - Update
    func updateSubsidiary(subsidiary: Subsidiary) {
        
    }
    //D - Delete
    func deleteSubsidiary(subsidiary: Subsidiary) {
        
    }
    func setDefaultSubsidiaryCompany(employee: Employee) {
        guard let employeeEntity = employee.toEmployeeEntity(context: self.mainContext) else {
            print("Empleado no existe en BD")
            return
        }
        guard let subsidiaryEntity = employeeEntity.toSubsidiary else {
            print("Empleado no tiene ninguna sibsidiaria")
            return
        }
        guard let companyEntity = subsidiaryEntity.toCompany else {
            print("Subsidiaria no tiene ninguna Compañia")
            return
        }
        self.mainCompanyEntity = companyEntity
    }
    func setDefaultCompany(company: Company) {
        guard let companyEntity = company.toCompanyEntity(context: self.mainContext) else {
            print("No se pudo asingar sucursar default")
            return
        }
        self.mainCompanyEntity = companyEntity
    }
    func getDefaultCompany() -> Company? {
        return self.mainCompanyEntity?.toCompany()
    }
}
