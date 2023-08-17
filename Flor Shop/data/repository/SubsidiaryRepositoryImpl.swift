//
//  SubsidiaryRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol SubsidiaryRepository {
    func addSubsidiary(subsidiary: Subsidiary)
    func getSubsidiary(id: UUID) -> Subsidiary
    func updateSubsidiary(subsidiary: Subsidiary)
    func deleteSubsidiary(subsidiary: Subsidiary)
}

class SubsidiaryRepositoryImpl: SubsidiaryRepository {
    let manager: SubsidiaryManager
    // let remote:  remoto, se puede implementar el remoto aqui
    init(manager: SubsidiaryManager) {
        self.manager = manager
    }
    //C - Create
    func addSubsidiary(subsidiary: Subsidiary) {
        self.manager.addSubsidiary(subsidiary: subsidiary)
    }
    //R - Read
    func getSubsidiary(id: UUID) -> Subsidiary {
        return self.manager.getSubsidiary(id: id)
    }
    //U - Update
    func updateSubsidiary(subsidiary: Subsidiary) {
        self.manager.updateSubsidiary(subsidiary: subsidiary)
    }
    //D - Delete
    func deleteSubsidiary(subsidiary: Subsidiary) {
        self.manager.deleteSubsidiary(subsidiary: subsidiary)
    }
}
