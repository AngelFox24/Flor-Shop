import Foundation
import CoreData
import FlorShop_DTOs

protocol LocalCompanyManager {
    func getLastUpdated() -> Date
    func sync(backgroundContext: NSManagedObjectContext, companyDTO: CompanyClientDTO) throws
    func getLastToken(context: NSManagedObjectContext) -> Int64
    func save(company: Company) throws
}

class LocalCompanyManagerImpl: LocalCompanyManager {
    let mainContext: NSManagedObjectContext
    let sessionConfig: SessionConfig
    let className = "[LocalCompanyManager]"
    init(
        mainContext: NSManagedObjectContext,
        sessionConfig: SessionConfig
    ) {
        self.mainContext = mainContext
        self.sessionConfig = sessionConfig
    }
    func getLastToken(context: NSManagedObjectContext) -> Int64 {
        let request: NSFetchRequest<Tb_Company> = Tb_Company.fetchRequest()
        let predicate = NSPredicate(format: "idCompany == %@ == %@ AND syncToken != nil", self.sessionConfig.companyId.uuidString)
        let sortDescriptor = NSSortDescriptor(key: "lastToken", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let syncToken = try self.mainContext.fetch(request).compactMap{$0.syncToken}.first
            return syncToken ?? 0
        } catch let error {
            print("Error fetching. \(error)")
            return 0
        }
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
    func sync(backgroundContext: NSManagedObjectContext, companyDTO: CompanyClientDTO) throws {
        guard self.sessionConfig.companyId == companyDTO.id else {
            print("La compañia no es la misma")
            rollback(context: backgroundContext)
            let cusError: String = "\(className): La compañia no es la misma"
            throw LocalStorageError.syncFailed(cusError)
        }
        if let companyEntity = try self.sessionConfig.getCompanyEntityById(context: backgroundContext, companyId: companyDTO.id) {
            guard !companyDTO.isEquals(to: companyEntity) else {
                print("\(className) No se actualiza, es lo mismo")
                return
            }
            companyEntity.companyName = companyDTO.companyName
            companyEntity.ruc = companyDTO.ruc
            companyEntity.createdAt = companyDTO.createdAt
            companyEntity.updatedAt = companyDTO.updatedAt
        } else {
//            print("Se crea la compañia")
            let newCompanyEntity = Tb_Company(context: backgroundContext)
            newCompanyEntity.idCompany = companyDTO.id
            newCompanyEntity.companyName = companyDTO.companyName
            newCompanyEntity.ruc = companyDTO.ruc
            newCompanyEntity.createdAt = companyDTO.createdAt
            newCompanyEntity.updatedAt = companyDTO.updatedAt
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
