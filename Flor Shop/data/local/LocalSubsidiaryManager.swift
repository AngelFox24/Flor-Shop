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
    func addSubsidiary(subsidiary: Subsidiary) {
        
    }
    //R - Read
    func getSubsidiary(id: UUID) -> Subsidiary {
        return Subsidiary(id: id, name: "Tienda de Flor", image: ImageUrl(id: id, mageUrl: "https://www.ceupe.com/images/easyblog_articles/3625/b2ap3_large_que-es-un-tienda-online.png"))
    }
    //U - Update
    func updateSubsidiary(subsidiary: Subsidiary) {
        
    }
    //D - Delete
    func deleteSubsidiary(subsidiary: Subsidiary) {
        
    }
}
