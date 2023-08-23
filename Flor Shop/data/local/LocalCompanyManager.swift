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
    func getCompany() -> Company?
    func updateCompany(company: Company)
    func deleteCompany(company: Company)
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
    //C - Create
    func addCompany(company: Company) -> Bool {
        guard let companyEntity = company.toCompanyEntity(context: self.mainContext) else {
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
    func getCompany() -> Company? {
        var companyEntity: Tb_Company?
        let request: NSFetchRequest<Tb_Company> = Tb_Company.fetchRequest()
        do {
            companyEntity = try self.mainContext.fetch(request).first
        } catch let error {
            print("Error fetching. \(error)")
        }
        return companyEntity?.toCompany()
    }
    //U - Update
    func updateCompany(company: Company) {
        
    }
    //D - Delete
    func deleteCompany(company: Company) {
        
    }
}
