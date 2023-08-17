//
//  LocalSubsidiaryManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol SubsidiaryManager {
    func addSubsidiary(subsidiary: Subsidiary)
    func getSubsidiary(id: UUID) -> Subsidiary
    func updateSubsidiary(subsidiary: Subsidiary)
    func deleteSubsidiary(subsidiary: Subsidiary)
}

class LocalSubsidiaryManager: SubsidiaryManager {
    let mainContext: NSManagedObjectContext
    func saveData() {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en LocalEmployeeManager: \(error)")
        }
    }
    func rollback() {
        do {
            try self.mainContext.rollback()
        } catch {
            print("Error al hacer rollback en LocalEmployeeManager: \(error)")
        }
    }
    //C - Create
    func addSubsidiary(subsidiary: Subsidiary) {
        
    }
    //R - Read
    func getSubsidiary(id: UUID) -> Subsidiary {
        return Subsidiary(idSubsidiary: id, name: "Tienda de Flor", image: ImageUrl(idImageUrl: id, mageUrl: "https://www.ceupe.com/images/easyblog_articles/3625/b2ap3_large_que-es-un-tienda-online.png"))
    }
    //U - Update
    func updateSubsidiary(subsidiary: Subsidiary) {
        
    }
    //D - Delete
    func deleteSubsidiary(subsidiary: Subsidiary) {
        
    }
}
