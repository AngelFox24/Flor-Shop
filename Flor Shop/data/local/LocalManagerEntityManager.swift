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
    func getManager() -> Manager?
    func updateManager(manager: Manager)
    func deleteManager(manager: Manager)
}

class LocalManagerEntityManager: ManagerEntityManager {
    let mainContext: NSManagedObjectContext
    init(mainContext: NSManagedObjectContext) {
        self.mainContext = mainContext
    }
    func saveData() {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en LocalManagerEntityManager: \(error)")
        }
    }
    func rollback() {
        self.mainContext.rollback()
    }
    //C - Create
    func addManager(manager: Manager) {
        if existManager(manager: manager) {
            print("El manager ya existe")
            rollback()
        } else {
            let newManager = Tb_Manager(context: mainContext)
            newManager.idManager = manager.id
            newManager.name = manager.name
            newManager.lastName = manager.lastName
            saveData()
        }
    }
    //R - Read
    func getManager() -> Manager? {
        var managerEntity: [Tb_Manager] = []
        let request: NSFetchRequest<Tb_Manager> = Tb_Manager.fetchRequest()
        do {
            managerEntity = try self.mainContext.fetch(request)
        } catch let error {
            print("Error fetching. \(error)")
        }
        return managerEntity.first?.toManager()
    }
    //U - Update
    func updateManager(manager: Manager) {
        
    }
    //D - Delete
    func deleteManager(manager: Manager) {
        
    }
    func existManager(manager: Manager) -> Bool {
        var managerEntity: Tb_Manager?
        let request: NSFetchRequest<Tb_Manager> = Tb_Manager.fetchRequest()
        var filterAtt = NSPredicate(format: "name == %@ AND lastName == %@", manager.name, manager.lastName)
        request.predicate = filterAtt
        do {
            managerEntity = try self.mainContext.fetch(request).first
        } catch let error {
            print("Error fetching. \(error)")
        }
        if managerEntity == nil {
            return false
        } else {
            return true
        }
    }
}
