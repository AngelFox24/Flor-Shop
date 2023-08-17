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
    func addCompany(company: Company) {
        
    }
    //R - Read
    func getCompany(id: UUID) -> Company {
        return Company(id: id, companyName: "MrProCompany", ruc: "2512115125")
    }
    //U - Update
    func updateCompany(company: Company) {
        
    }
    //D - Delete
    func deleteCompany(company: Company) {
        
    }
}
