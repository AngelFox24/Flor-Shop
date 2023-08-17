//
//  ManagerRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol ManagerRepository {
    func addManager(manager: Manager)
    func getManager() -> Manager?
    func updateManager(manager: Manager)
    func deleteManager(manager: Manager)
}

class ManagerRepositoryImpl: ManagerRepository {
    let manager: ManagerEntityManager
    // let remote:  remoto, se puede implementar el remoto aqui
    init(manager: ManagerEntityManager) {
        self.manager = manager
    }
    //C - Create
    func addManager(manager: Manager) {
        self.manager.addManager(manager: manager)
    }
    //R - Read
    func getManager() -> Manager? {
        return self.manager.getManager()
    }
    //U - Update
    func updateManager(manager: Manager) {
        self.manager.updateManager(manager: manager)
    }
    //D - Delete
    func deleteManager(manager: Manager) {
        self.manager.deleteManager(manager: manager)
    }
}
