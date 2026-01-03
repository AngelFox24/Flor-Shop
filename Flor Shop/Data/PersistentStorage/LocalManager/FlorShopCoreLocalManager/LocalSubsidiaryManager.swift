import Foundation
import CoreData
import FlorShopDTOs

protocol LocalSubsidiaryManager {
    func sync(backgroundContext: NSManagedObjectContext, subsidiariesDTOs: [SubsidiaryClientDTO]) throws
    func getLastToken() -> Int64
    func getLastToken(context: NSManagedObjectContext) -> Int64
    func save(subsidiary: Subsidiary) throws
    func getSubsidiaries() -> [Subsidiary]
}

class LocalSubsidiaryManagerImpl: LocalSubsidiaryManager {
    let sessionConfig: SessionConfig
    let mainContext: NSManagedObjectContext
    let className = "[LocalSubsidiaryManager]"
    init(
        mainContext: NSManagedObjectContext,
        sessionConfig: SessionConfig
    ) {
        self.mainContext = mainContext
        self.sessionConfig = sessionConfig
    }
    func getLastToken() -> Int64 {
        return self.getLastToken(context: self.mainContext)
    }
    func getLastToken(context: NSManagedObjectContext) -> Int64 {
        let request: NSFetchRequest<Tb_Subsidiary> = Tb_Subsidiary.fetchRequest()
        let predicate = NSPredicate(format: "toCompany.companyCic == %@ AND syncToken != nil", self.sessionConfig.companyCic)
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
    func save(subsidiary: Subsidiary) throws {
        if let subsidiaryCic = subsidiary.subsidiaryCic,
           let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityByCic(context: self.mainContext, subsidiaryCic: subsidiaryCic) {
            subsidiaryEntity.name = subsidiary.name
            subsidiaryEntity.imageUrl = subsidiary.imageUrl
            subsidiaryEntity.toCompany?.companyCic = self.sessionConfig.companyCic
        } else {
            let newSubsidiaryEntity = Tb_Subsidiary(context: self.mainContext)
            newSubsidiaryEntity.subsidiaryCic = UUID().uuidString
            newSubsidiaryEntity.name = subsidiary.name
            newSubsidiaryEntity.imageUrl = subsidiary.imageUrl
            newSubsidiaryEntity.toCompany?.companyCic = self.sessionConfig.companyCic
        }
        try saveData()
    }
    func sync(backgroundContext: NSManagedObjectContext, subsidiariesDTOs: [SubsidiaryClientDTO]) throws {
        for subsidiaryDTO in subsidiariesDTOs {
            guard self.sessionConfig.companyCic == subsidiaryDTO.companyCic else {
                rollback(context: backgroundContext)
                let cusError: String = "\(className): La compañia no es la misma"
                throw LocalStorageError.syncFailed(cusError)
            }
            guard let companyEntity = try self.sessionConfig.getCompanyEntityByCic(context: backgroundContext, companyCic: subsidiaryDTO.companyCic) else {
                rollback(context: backgroundContext)
                let cusError: String = "\(className): No se pudo obtener la compañia de la BD"
                throw LocalStorageError.syncFailed(cusError)
            }
            if let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityByCic(context: backgroundContext, subsidiaryCic: subsidiaryDTO.subsidiaryCic) {
                guard !subsidiaryDTO.isEquals(to: subsidiaryEntity) else {
                    print("\(className) No se actualiza, es lo mismo")
                    continue
                }
                subsidiaryEntity.name = subsidiaryDTO.name
                subsidiaryEntity.imageUrl = subsidiaryDTO.imageUrl
                subsidiaryEntity.syncToken = subsidiaryDTO.syncToken
                subsidiaryEntity.createdAt = subsidiaryDTO.createdAt
                subsidiaryEntity.updatedAt = subsidiaryDTO.updatedAt
                try saveData(context: backgroundContext)
            } else {
                let newSubsidiaryEntity = Tb_Subsidiary(context: backgroundContext)
                newSubsidiaryEntity.subsidiaryCic = subsidiaryDTO.subsidiaryCic
                newSubsidiaryEntity.name = subsidiaryDTO.name
                newSubsidiaryEntity.syncToken = subsidiaryDTO.syncToken
                newSubsidiaryEntity.imageUrl = subsidiaryDTO.imageUrl
                newSubsidiaryEntity.toCompany = companyEntity
                newSubsidiaryEntity.createdAt = subsidiaryDTO.createdAt
                newSubsidiaryEntity.updatedAt = subsidiaryDTO.updatedAt
                try saveData(context: backgroundContext)
            }
        }
    }
    func getSubsidiaries() -> [Subsidiary] {
        let filterAtt = NSPredicate(format: "toCompany.companyCic == %@", self.sessionConfig.companyCic)
        let request: NSFetchRequest<Tb_Subsidiary> = Tb_Subsidiary.fetchRequest()
        request.predicate = filterAtt
        do {
            let result = try self.mainContext.fetch(request)
            return result.compactMap { try? $0.toSubsidiary() }
        } catch let error {
            print("Error fetching. \(error)")
            return []
        }
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
    private func rollback() {
        self.mainContext.rollback()
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
}
