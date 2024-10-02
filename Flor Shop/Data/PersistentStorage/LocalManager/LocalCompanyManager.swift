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
    func sync(backgroundContext: NSManagedObjectContext, companyDTO: CompanyDTO) throws
    func save(company: Company) throws
}

class LocalCompanyManagerImpl: LocalCompanyManager {
    let mainContext: NSManagedObjectContext
    let sessionConfig: SessionConfig
    let className = "LocalCompanyManager"
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
    func sync(backgroundContext: NSManagedObjectContext, companyDTO: CompanyDTO) throws {
        guard self.sessionConfig.companyId == companyDTO.id else {
            print("La compañia no es la misma")
            rollback(context: backgroundContext)
            let cusError: String = "\(className): La compañia no es la misma"
            throw LocalStorageError.syncFailed(cusError)
        }
        if let companyEntity = try self.sessionConfig.getCompanyEntityById(context: backgroundContext, companyId: companyDTO.id) {
//            print("Se actualiza la compañia")
            companyEntity.companyName = companyDTO.companyName
            companyEntity.ruc = companyDTO.ruc
            companyEntity.createdAt = companyDTO.createdAt.internetDateTime()
            companyEntity.updatedAt = companyDTO.updatedAt.internetDateTime()
        } else {
//            print("Se crea la compañia")
            let newCompanyEntity = Tb_Company(context: self.mainContext)
            newCompanyEntity.idCompany = companyDTO.id
            newCompanyEntity.companyName = companyDTO.companyName
            newCompanyEntity.ruc = companyDTO.ruc
            newCompanyEntity.createdAt = companyDTO.createdAt.internetDateTime()
            newCompanyEntity.updatedAt = companyDTO.updatedAt.internetDateTime()
        }
//        print("Se guardara los datos en LocalCompanyManager")
        try saveData(context: backgroundContext)
    }
    func save(company: Company) throws {
        if let companyEntity = try self.sessionConfig.getCompanyEntityById(context: self.mainContext, companyId: company.id) { //Comprobacion Inicial por Id
            companyEntity.companyName = company.companyName
            companyEntity.ruc = company.ruc
        } else if try companyExist(company: company) { //Buscamos compañia por otros atributos
            throw LocalStorageError.saveFailed("La compañia ya existe")
        } else { //Creamos una nueva comañia
            let newCompany = Tb_Company(context: mainContext)
            newCompany.idCompany = company.id
            newCompany.companyName = company.companyName
            newCompany.ruc = company.ruc
        }
        try saveData()
    }
    //MARK: Private Funtions
    private func saveData() throws {
        do {
            try self.mainContext.save()
        } catch {
            rollback()
            let cusError: String = "\(className): \(error.localizedDescription)"
            throw LocalStorageError.saveFailed(cusError)
        }
    }
    private func saveData(context: NSManagedObjectContext) throws {
        do {
            try context.save()
        } catch {
            rollback(context: context)
            let cusError: String = "\(className) - BackgroundContext: \(error.localizedDescription)"
            throw LocalStorageError.saveFailed(cusError)
        }
    }
    private func rollback(context: NSManagedObjectContext) {
        context.rollback()
    }
    private func rollback() {
        self.mainContext.rollback()
    }
    private func companyExist(company: Company) throws -> Bool {
        let filterAtt = NSPredicate(format: "companyName == %@ OR ruc == %@", company.companyName, company.ruc)
        let request: NSFetchRequest<Tb_Company> = Tb_Company.fetchRequest()
        request.predicate = filterAtt
        do {
            let total = try self.mainContext.fetch(request).count
            return total == 0 ? false : true
        } catch let error {
            let cusError: String = "\(className): \(error.localizedDescription)"
            throw LocalStorageError.fetchFailed(cusError)
        }
    }
}
