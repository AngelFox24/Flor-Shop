//
//  CompanyRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol CompanyRepository {
    func addCompany(company: Company)
    func getCompany(id: UUID) -> Company
    func updateCompany(company: Company)
    func deleteCompany(company: Company)
}

class CompanyRepositoryImpl: CompanyRepository {
    let manager: CompanyManager
    // let remote:  remoto, se puede implementar el remoto aqui
    init(manager: CompanyManager) {
        self.manager = manager
    }
    //C - Create
    func addCompany(company: Company) {
        self.manager.addCompany(company: company)
    }
    //R - Read
    func getCompany(id: UUID) -> Company {
        return self.manager.getCompany(id: id)
    }
    //U - Update
    func updateCompany(company: Company) {
        self.manager.updateCompany(company: company)
    }
    //D - Delete
    func deleteCompany(company: Company) {
        self.manager.deleteCompany(company: company)
    }
}
