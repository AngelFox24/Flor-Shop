//
//  LocalCompanyManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol CompanyManager {
    func addCompany(company: Company, manager: Manager)
    func getCompany() -> Company?
    func updateCompany(company: Company)
    func deleteCompany(company: Company)
}

class LocalCompanyManager: CompanyManager {
    let mainContext: NSManagedObjectContext
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
    func addCompany(company: Company, manager: Manager) {
        if existCompany(company: company) {
            print("La empresa ya existe")
            rollback()
        } else {
            let newCompany = Tb_Company(context: mainContext)
            newCompany.idCompany = company.id
            newCompany.companyName = company.companyName
            newCompany.ruc = company.ruc
            newCompany.toManager = manager.toManagerEntity(context: mainContext)
            saveData()
        }
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
    func existCompany(company: Company) -> Bool {
        var companyEntity: Tb_Manager?
        let request: NSFetchRequest<Tb_Manager> = Tb_Manager.fetchRequest()
        let filterAtt = NSPredicate(format: "companyName == %@ AND ruc == %@", company.companyName, company.ruc)
        request.predicate = filterAtt
        do {
            companyEntity = try self.mainContext.fetch(request).first
        } catch let error {
            print("Error fetching. \(error)")
        }
        if companyEntity == nil {
            return false
        } else {
            return true
        }
    }
}
