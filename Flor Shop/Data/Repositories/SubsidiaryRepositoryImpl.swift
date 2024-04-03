//
//  SubsidiaryRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol SubsidiaryRepository {
    func addSubsidiary(subsidiary: Subsidiary) -> Bool
    func getSubsidiaries() -> [Subsidiary]
    func updateSubsidiary(subsidiary: Subsidiary)
    func deleteSubsidiary(subsidiary: Subsidiary)
    func setDefaultCompany(company: Company)
    func setDefaultSubsidiaryCompany(employee: Employee)
    func getDefaulCompany() -> Company?
    func getCompany(subsidiary: Subsidiary) -> Company?
    func releaseResourses()
}

class SubsidiaryRepositoryImpl: SubsidiaryRepository {
    let manager: SubsidiaryManager
    // let remote:  remoto, se puede implementar el remoto aqui
    init(manager: SubsidiaryManager) {
        self.manager = manager
    }
    //C - Create
    func addSubsidiary(subsidiary: Subsidiary) -> Bool {
        return self.manager.addSubsidiary(subsidiary: subsidiary)
    }
    //R - Read
    func getSubsidiaries() -> [Subsidiary] {
        return self.manager.getSubsidiaries()
    }
    //U - Update
    func updateSubsidiary(subsidiary: Subsidiary) {
        self.manager.updateSubsidiary(subsidiary: subsidiary)
    }
    //D - Delete
    func deleteSubsidiary(subsidiary: Subsidiary) {
        self.manager.deleteSubsidiary(subsidiary: subsidiary)
    }
    func setDefaultCompany(company: Company) {
        self.manager.setDefaultCompany(company: company)
    }
    func setDefaultSubsidiaryCompany(employee: Employee) {
        self.manager.setDefaultSubsidiaryCompany(employee: employee)
    }
    func getCompany(subsidiary: Subsidiary) -> Company? {
        return self.manager.getCompany(subsidiary: subsidiary)
    }
    func getDefaulCompany() -> Company? {
        return self.manager.getDefaultCompany()
    }
    func releaseResourses() {
        self.manager.releaseResourses()
    }
}
