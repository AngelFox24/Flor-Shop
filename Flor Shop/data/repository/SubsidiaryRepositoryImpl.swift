//
//  SubsidiaryRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol SubsidiaryRepository {
    func addSubsidiary(subsidiary: Subsidiary, company: Company) -> Bool
    func getSubsidiary() -> Subsidiary?
    func updateSubsidiary(subsidiary: Subsidiary)
    func deleteSubsidiary(subsidiary: Subsidiary)
    func setDefaultSubsidiary(employee: Employee)
    func getSubsidiaryCompany() -> Company?
}

class SubsidiaryRepositoryImpl: SubsidiaryRepository {
    let manager: SubsidiaryManager
    // let remote:  remoto, se puede implementar el remoto aqui
    init(manager: SubsidiaryManager) {
        self.manager = manager
    }
    //C - Create
    func addSubsidiary(subsidiary: Subsidiary, company: Company) -> Bool {
        return self.manager.addSubsidiary(subsidiary: subsidiary, company: company)
    }
    //R - Read
    func getSubsidiary() -> Subsidiary? {
        return self.manager.getSubsidiary()
    }
    //U - Update
    func updateSubsidiary(subsidiary: Subsidiary) {
        self.manager.updateSubsidiary(subsidiary: subsidiary)
    }
    //D - Delete
    func deleteSubsidiary(subsidiary: Subsidiary) {
        self.manager.deleteSubsidiary(subsidiary: subsidiary)
    }
    func setDefaultSubsidiary(employee: Employee) {
        self.manager.setDefaultSubsidiary(employee: employee)
    }
    func getSubsidiaryCompany() -> Company? {
        return self.manager.getSubsidiaryCompany()
    }
}
