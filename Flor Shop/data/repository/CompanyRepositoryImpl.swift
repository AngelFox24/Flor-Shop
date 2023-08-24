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
    func getCompany() -> Company?
    func updateCompany(company: Company)
    func deleteCompany(company: Company)
    func setDefaultCompany(employee: Employee)
}

class CompanyRepositoryImpl: CompanyRepository {
    let companyManager: CompanyManager
    // let remote:  remoto, se puede implementar el remoto aqui
    init(companyManager: CompanyManager) {
        self.companyManager = companyManager
    }
    //C - Create
    func addCompany(company: Company) -> Bool {
        self.companyManager.addCompany(company: company)
    }
    //R - Read
    func getCompany() -> Company? {
        return self.companyManager.getCompany()
    }
    //U - Update
    func updateCompany(company: Company) {
        self.companyManager.updateCompany(company: company)
    }
    //D - Delete
    func deleteCompany(company: Company) {
        self.companyManager.deleteCompany(company: company)
    }
    func setDefaultCompany(employee: Employee) {
        self.companyManager.setDefaultCompany(employee: employee)
    }
}
