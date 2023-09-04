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
        if company.toCompanyEntity(context: self.mainContext) != nil { //Comprobacion Inicial por Id
            rollback()
            return false
        } else if companyExist(company: company) { //Buscamos compañia por otros atributos
            rollback()
            return false
        } else { //Creamos una nueva comañia
            let newCompany = Tb_Company(context: mainContext)
            newCompany.idCompany = company.id
            newCompany.companyName = company.companyName
            newCompany.ruc = company.ruc
            self.mainCompanyEntity = newCompany
            saveData()
            return true
        }
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
    func companyExist(company: Company) -> Bool {
        let filterAtt = NSPredicate(format: "companyName == %@ OR ruc == %@", company.companyName, company.ruc)
        let request: NSFetchRequest<Tb_Company> = Tb_Company.fetchRequest()
        request.predicate = filterAtt
        do {
            let total = try self.mainContext.fetch(request).count
            return total == 0 ? false : true
        } catch let error {
            print("Error fetching. \(error)")
            return false
        }
    }
}
