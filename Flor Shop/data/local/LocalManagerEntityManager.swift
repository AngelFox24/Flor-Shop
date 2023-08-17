//
//  LocalManagerEntityManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol ManagerEntityManager {
    func addManager(manager: Manager)
    func getManager(id: UUID) -> Manager
    func updateManager(manager: Manager)
    func deleteManager(manager: Manager)
}

class LocalManagerEntityManager: ManagerEntityManager {
    let mainContext: NSManagedObjectContext
    func saveData() {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en LocalManagerEntityManager: \(error)")
        }
    }
    func rollback() {
        do {
            try self.mainContext.rollback()
        } catch {
            print("Error al hacer rollback en LocalManagerEntityManager: \(error)")
        }
    }
    //C - Create
    func addManager(manager: Manager) {
        
    }
    //R - Read
    func getManager(id: UUID) -> Manager {
        return Manager(idManager: id, name: "Angel", lastName: "Curi Laurente")
    }
    //U - Update
    func updateManager(manager: Manager) {
        
    }
    //D - Delete
    func deleteManager(manager: Manager) {
        
    }
}
