import Foundation
import CoreData
import FlorShopDTOs

protocol LocalCompanyManager {
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
        let predicate = NSPredicate(format: "companyCic == %@ AND syncToken != nil", self.sessionConfig.companyCic)
        let sortDescriptor = NSSortDescriptor(key: "syncToken", ascending: false)
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
    func sync(backgroundContext: NSManagedObjectContext, companyDTO: CompanyClientDTO) throws {
        guard self.sessionConfig.companyCic == companyDTO.companyCic else {
            print("La compañia no es la misma")
            rollback(context: backgroundContext)
            let cusError: String = "\(className): La compañia no es la misma"
            throw LocalStorageError.syncFailed(cusError)
        }
        if let companyEntity = try self.sessionConfig.getCompanyEntityByCic(context: backgroundContext, companyCic: companyDTO.companyCic) {
            guard !companyDTO.isEquals(to: companyEntity) else {
                print("\(className) No se actualiza, es lo mismo")
                return
            }
            companyEntity.companyName = companyDTO.companyName
            companyEntity.ruc = companyDTO.ruc
            companyEntity.syncToken = companyDTO.syncToken
            companyEntity.createdAt = companyDTO.createdAt
            companyEntity.updatedAt = companyDTO.updatedAt
        } else {
//            print("Se crea la compañia")
            let newCompanyEntity = Tb_Company(context: backgroundContext)
            newCompanyEntity.companyCic = companyDTO.companyCic
            newCompanyEntity.companyName = companyDTO.companyName
            newCompanyEntity.ruc = companyDTO.ruc
            newCompanyEntity.syncToken = companyDTO.syncToken
            newCompanyEntity.createdAt = companyDTO.createdAt
            newCompanyEntity.updatedAt = companyDTO.updatedAt
        }
//        print("Se guardara los datos en LocalCompanyManager")
        try saveData(context: backgroundContext)
    }
    func save(company: Company) throws {
        if let companyCic = company.companyCic,
           let companyEntity = try self.sessionConfig.getCompanyEntityByCic(context: self.mainContext, companyCic: companyCic) { //Comprobacion Inicial por Id
            companyEntity.companyName = company.companyName
            companyEntity.ruc = company.ruc
        } else if try companyExist(company: company) { //Buscamos compañia por otros atributos
            throw LocalStorageError.saveFailed("La compañia ya existe")
        } else { //Creamos una nueva comañia
            let newCompany = Tb_Company(context: mainContext)
            newCompany.companyCic = UUID().uuidString
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
