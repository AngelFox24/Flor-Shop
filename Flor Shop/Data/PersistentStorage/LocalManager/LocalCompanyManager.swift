//
//  LocalCompanyManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol LocalCompanyManager {
    func getLastUpdated() throws -> Date?
    func sync(companyDTO: CompanyDTO) throws
    func save(company: Company) throws
}

class LocalCompanyManagerImpl: LocalCompanyManager {
    let mainContext: NSManagedObjectContext
    let sessionConfig: SessionConfig
    init(
        mainContext: NSManagedObjectContext,
        sessionConfig: SessionConfig
    ) {
        self.mainContext = mainContext
        self.sessionConfig = sessionConfig
    }
    func getLastUpdated() throws -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 1999, month: 1, day: 1)
        let dateFrom = calendar.date(from: components)
        let request: NSFetchRequest<Tb_Company> = Tb_Company.fetchRequest()
        let predicate = NSPredicate(format: "idCompany == %@ AND updatedAt != nil", self.sessionConfig.companyId.uuidString)
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.fetchLimit = 1
        let listDate = try self.mainContext.fetch(request).map{$0.updatedAt}
        guard let last = listDate[0] else {
            print("Se retorna valor por defecto")
            return dateFrom
        }
        print("Se retorna valor desde la BD")
        return last
    }
    func sync(companyDTO: CompanyDTO) throws {
        guard self.sessionConfig.companyId == companyDTO.id else {
            throw LocalStorageError.notFound("La compañia no es la misma")
        }
        if let companyEntity = getCompanyEntityById(companyId: companyDTO.id) {
            companyEntity.companyName = companyDTO.companyName
            companyEntity.ruc = companyDTO.ruc
            companyEntity.createdAt = companyDTO.createdAt.internetDateTime()
            companyEntity.updatedAt = companyDTO.updatedAt.internetDateTime()
        } else {
            let newCompanyEntity = Tb_Company(context: self.mainContext)
            newCompanyEntity.idCompany = companyDTO.id
            newCompanyEntity.companyName = companyDTO.companyName
            newCompanyEntity.ruc = companyDTO.ruc
            newCompanyEntity.createdAt = companyDTO.createdAt.internetDateTime()
            newCompanyEntity.updatedAt = companyDTO.updatedAt.internetDateTime()
        }
        saveData()
    }
    func save(company: Company) throws {
        if let companyEntity = getCompanyEntityById(companyId: company.id) { //Comprobacion Inicial por Id
            companyEntity.companyName = company.companyName
            companyEntity.ruc = company.ruc
        } else if companyExist(company: company) { //Buscamos compañia por otros atributos
            throw LocalStorageError.notFound("La compañia ya existe")
        } else { //Creamos una nueva comañia
            let newCompany = Tb_Company(context: mainContext)
            newCompany.idCompany = company.id
            newCompany.companyName = company.companyName
            newCompany.ruc = company.ruc
        }
        saveData()
    }
    //MARK: Private Funtions
    private func saveData() {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en LocalEmployeeManager: \(error)")
        }
    }
    private func rollback() {
        self.mainContext.rollback()
    }
    private func companyExist(company: Company) -> Bool {
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
    private func getCompanyEntityById(companyId: UUID) -> Tb_Company? {
        let request: NSFetchRequest<Tb_Company> = Tb_Company.fetchRequest()
        let predicate = NSPredicate(format: "idCompany == %@", self.sessionConfig.companyId.uuidString)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try self.mainContext.fetch(request).first
            return result
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
}
