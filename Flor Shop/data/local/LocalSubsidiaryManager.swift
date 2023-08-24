//
//  LocalSubsidiaryManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol SubsidiaryManager {
    func addSubsidiary(subsidiary: Subsidiary, company: Company) -> Bool
    func getSubsidiary() -> Subsidiary?
    func updateSubsidiary(subsidiary: Subsidiary)
    func deleteSubsidiary(subsidiary: Subsidiary)
    func setDefaultSubsidiary(employee: Employee)
}

class LocalSubsidiaryManager: SubsidiaryManager {
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
    //C - Create
    func addSubsidiary(subsidiary: Subsidiary, company: Company) -> Bool {
        guard let companyEntity = company.toCompanyEntity(context: self.mainContext) else {
            print("No existe compañia para crear una sucursal")
            rollback()
            return false
        }
        if let subsidiaryEntity = subsidiary.toSubsidiaryEntity(context: self.mainContext) {
            print("Ya existe sucursal, no se puede crear")
            rollback()
            return false
        } else {
            let newSubsidiaryEntity = Tb_Subsidiary(context: self.mainContext)
            newSubsidiaryEntity.idSubsidiary = subsidiary.id
            newSubsidiaryEntity.name = subsidiary.name
            newSubsidiaryEntity.toImageUrl = subsidiary.image.toImageUrlEntity(context: self.mainContext) ?? ImageUrl.getDummyImage().toImageUrlEntity(context: self.mainContext)
            newSubsidiaryEntity.toCompany = companyEntity
            saveData()
            return true
        }
    }
    //R - Read
    func getSubsidiary() -> Subsidiary? {
        var subsidiaryEntity: Tb_Subsidiary?
        let request: NSFetchRequest<Tb_Subsidiary> = Tb_Subsidiary.fetchRequest()
        do {
            subsidiaryEntity = try self.mainContext.fetch(request).first
        } catch let error {
            print("Error fetching. \(error)")
        }
        return subsidiaryEntity?.toSubsidiary()
    }
    //U - Update
    func updateSubsidiary(subsidiary: Subsidiary) {
        
    }
    //D - Delete
    func deleteSubsidiary(subsidiary: Subsidiary) {
        
    }
    func existSubsidiary(subsidiary: Subsidiary) -> Bool {
        var subsidiaryEntity: Tb_Subsidiary?
        let request: NSFetchRequest<Tb_Subsidiary> = Tb_Subsidiary.fetchRequest()
        let filterAtt = NSPredicate(format: "name == %@", subsidiary.name)
        request.predicate = filterAtt
        do {
            subsidiaryEntity = try self.mainContext.fetch(request).first
        } catch let error {
            print("Error fetching. \(error)")
        }
        if subsidiaryEntity == nil {
            return false
        } else {
            return true
        }
    }
    func setDefaultSubsidiary(employee: Employee) {
        let employeeEntity = employee.toEmployeeEntity(context: mainContext)
        guard let employeeEntity = employee.toEmployeeEntity(context: mainContext), let subsidiaryEntity: Tb_Subsidiary = employeeEntity.toSubsidiary else {
            print("No se pudo asingar sucursar default")
            return
        }
        self.mainSubsidiaryEntity = subsidiaryEntity
    }
    func setDefaultSubsidiary(subsidiary: Subsidiary) {
        guard let subsidiaryEntity = subsidiary.toSubsidiaryEntity(context: self.mainContext) else {
            print("No se pudo asingar sucursar default")
            return
        }
        self.mainSubsidiaryEntity = subsidiaryEntity
    }
}
