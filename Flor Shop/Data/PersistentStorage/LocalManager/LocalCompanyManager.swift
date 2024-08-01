//
//  LocalCompanyManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol LocalCompanyManager {
    func getLastUpdated() -> Date
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
    func getLastUpdated() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 1999, month: 1, day: 1)
        let dateFrom = calendar.date(from: components)
        let request: NSFetchRequest<Tb_Company> = Tb_Company.fetchRequest()
        let predicate = NSPredicate(format: "idCompany == %@ AND updatedAt != nil", self.sessionConfig.companyId.uuidString)
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let date = try self.mainContext.fetch(request).compactMap{$0.updatedAt}.first
            guard let dateNN = date else {
                return dateFrom!
            }
            return dateNN
        } catch let error {
            print("Error fetching. \(error)")
            return dateFrom!
        }
    }
    func sync(companyDTO: CompanyDTO) throws {
        guard self.sessionConfig.companyId == companyDTO.id else {
            print("La compañia no es la misma")
            rollback()
            throw LocalStorageError.notFound("La compañia no es la misma")
        }
        if let companyEntity = self.sessionConfig.getCompanyEntityById(context: self.mainContext, companyId: companyDTO.id) {
            print("Se actualiza la compañia")
            companyEntity.companyName = companyDTO.companyName
            companyEntity.ruc = companyDTO.ruc
            companyEntity.createdAt = companyDTO.createdAt.internetDateTime()
            companyEntity.updatedAt = companyDTO.updatedAt.internetDateTime()
        } else {
            print("Se crea la compañia")
            let newCompanyEntity = Tb_Company(context: self.mainContext)
            newCompanyEntity.idCompany = companyDTO.id
            newCompanyEntity.companyName = companyDTO.companyName
            newCompanyEntity.ruc = companyDTO.ruc
            newCompanyEntity.createdAt = companyDTO.createdAt.internetDateTime()
            newCompanyEntity.updatedAt = companyDTO.updatedAt.internetDateTime()
        }
        print("Se guardara los datos en LocalCompanyManager")
        saveData()
    }
    func save(company: Company) throws {
        if let companyEntity = self.sessionConfig.getCompanyEntityById(context: self.mainContext, companyId: company.id) { //Comprobacion Inicial por Id
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
            print("Error al guardar en LocalCompanyManager: \(error)")
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
}
