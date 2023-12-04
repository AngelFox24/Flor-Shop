//
//  CompanyRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol CompanyRepository {
    func addCompany(company: Company) -> Bool
    func getDefaultCompany() -> Company?
    func updateCompany(company: Company)
    func deleteCompany(company: Company)
    func setDefaultCompany(employee: Employee)
    func setDefaultCompany(company: Company)
}

class CompanyRepositoryImpl: CompanyRepository {
    let manager: CompanyManager
    // let remote:  remoto, se puede implementar el remoto aqui
    init(manager: CompanyManager) {
        self.manager = manager
    }
    //C - Create
    func addCompany(company: Company) -> Bool {
        self.manager.addCompany(company: company)
    }
    //R - Read
    func getDefaultCompany() -> Company? {
        return self.manager.getDefaultCompany()
    }
    //U - Update
    func updateCompany(company: Company) {
        self.manager.updateCompany(company: company)
    }
    //D - Delete
    func deleteCompany(company: Company) {
        self.manager.deleteCompany(company: company)
    }
    func setDefaultCompany(employee: Employee) {
        self.manager.setDefaultCompany(employee: employee)
    }
    func setDefaultCompany(company: Company) {
        self.manager.setDefaultCompany(company: company)
    }
}
