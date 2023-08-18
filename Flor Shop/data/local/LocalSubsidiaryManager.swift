//
//  LocalSubsidiaryManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol SubsidiaryManager {
    func addSubsidiary(subsidiary: Subsidiary, company: Company)
    func getSubsidiary() -> Subsidiary?
    func updateSubsidiary(subsidiary: Subsidiary)
    func deleteSubsidiary(subsidiary: Subsidiary)
}

class LocalSubsidiaryManager: SubsidiaryManager {
    let mainContext: NSManagedObjectContext
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
    func addSubsidiary(subsidiary: Subsidiary, company: Company) {
            if existSubsidiary(subsidiary: subsidiary) {
                print("La sucursal ya existe")
                rollback()
            } else {
                let newSubsidiary = Tb_Subsidiary(context: mainContext)
                newSubsidiary.idSubsidiary = subsidiary.id
                newSubsidiary.name = subsidiary.name
                newSubsidiary.toCompany = company.toCompanyEntity(context: mainContext)
                newSubsidiary.toImageUrl = subsidiary.image.toImageUrlEntity(context: mainContext)
                saveData()
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
}
