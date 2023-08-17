//
//  LocalCompanyManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol CompanyManager {
    func addCompany(company: Company)
    func getCompany(id: UUID) -> Company
    func updateCompany(company: Company)
    func deleteCompany(company: Company)
}

class LocalCompanyManager: CompanyManager {
    let mainContext: NSManagedObjectContext
    func saveData() {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en LocalEmployeeManager: \(error)")
        }
    }
    func rollback() {
        do {
            try self.mainContext.rollback()
        } catch {
            print("Error al hacer rollback en LocalEmployeeManager: \(error)")
        }
    }
    //C - Create
    func addCompany(company: Company) {
        
    }
    //R - Read
    func getCompany(id: UUID) -> Company {
        return Company(idCompany: id, companyName: "MrProCompany", ruc: "2512115125")
    }
    //U - Update
    func updateCompany(company: Company) {
        
    }
    //D - Delete
    func deleteCompany(company: Company) {
        
    }
}
