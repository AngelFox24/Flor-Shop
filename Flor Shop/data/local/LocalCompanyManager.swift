//
//  LocalCompanyManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol CompanyManager {
    func addCompany(company: Company) -> Bool
    func getDefaultCompany() -> Company?
    func updateCompany(company: Company)
    func deleteCompany(company: Company)
    func setDefaultCompany(company: Company)
    func setDefaultCompany(employee: Employee)
}

class LocalCompanyManager: CompanyManager {
    let mainContext: NSManagedObjectContext
    var mainCompanyEntity: Tb_Company?
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
    func setDefaultCompany(company: Company) {
        guard let companyEntity = company.toCompanyEntity(context: self.mainContext) else {
            print("No se pudo asingar compañia default")
            return
        }
        self.mainCompanyEntity = companyEntity
    }
    func setDefaultCompany(employee: Employee) {
        guard let employeeEntity = employee.toEmployeeEntity(context: self.mainContext), let companyEntity = employeeEntity.toSubsidiary?.toCompany else {
            print("No se pudo asingar compañia default")
            return
        }
        self.mainCompanyEntity = companyEntity
    }
    //C - Create
    func addCompany(company: Company) -> Bool {
        guard let _ = company.toCompanyEntity(context: self.mainContext) else {
            let newCompany = Tb_Company(context: mainContext)
            newCompany.idCompany = company.id
            newCompany.companyName = company.companyName
            newCompany.ruc = company.ruc
            self.mainCompanyEntity = newCompany
            saveData()
            return true
        }
        rollback()
        return false
    }
    //R - Read
    func getDefaultCompany() -> Company? {
        return mainCompanyEntity?.toCompany()
    }
    //U - Update
    func updateCompany(company: Company) {
        
    }
    //D - Delete
    func deleteCompany(company: Company) {
        
    }
}
