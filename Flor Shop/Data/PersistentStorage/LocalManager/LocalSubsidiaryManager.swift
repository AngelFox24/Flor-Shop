import Foundation
import CoreData
import FlorShop_DTOs

protocol LocalSubsidiaryManager {
    func sync(backgroundContext: NSManagedObjectContext, subsidiariesDTOs: [SubsidiaryClientDTO]) throws
    func getLastToken(context: NSManagedObjectContext) -> Int64
    func save(subsidiary: Subsidiary) throws
    func getLastUpdated() -> Date
    func getSubsidiaries() -> [Subsidiary]
}

class LocalSubsidiaryManagerImpl: LocalSubsidiaryManager {
    let sessionConfig: SessionConfig
    let mainContext: NSManagedObjectContext
    let imageService: LocalImageService
    let className = "[LocalSubsidiaryManager]"
    init(
        mainContext: NSManagedObjectContext,
        sessionConfig: SessionConfig,
        imageService: LocalImageService
    ) {
        self.mainContext = mainContext
        self.sessionConfig = sessionConfig
        self.imageService = imageService
    }
    func getLastToken(context: NSManagedObjectContext) -> Int64 {
        let request: NSFetchRequest<Tb_Subsidiary> = Tb_Subsidiary.fetchRequest()
        let predicate = NSPredicate(format: "toCompany.idCompany == %@ AND syncToken != nil", self.sessionConfig.companyId.uuidString)
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
    func getLastUpdated() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 1999, month: 1, day: 1)
        let dateFrom = calendar.date(from: components)
        let request: NSFetchRequest<Tb_Subsidiary> = Tb_Subsidiary.fetchRequest()
        let predicate = NSPredicate(format: "toCompany.idCompany == %@ AND updatedAt != nil", self.sessionConfig.companyId.uuidString)
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
    func save(subsidiary: Subsidiary) throws {
        let image = try self.imageService.saveIfExist(context: self.mainContext, image: subsidiary.image)
        if let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityById(context: self.mainContext, subsidiaryId: subsidiary.id) {
            subsidiaryEntity.idSubsidiary = subsidiary.id
            subsidiaryEntity.name = subsidiary.name
            subsidiaryEntity.toImageUrl = image
            subsidiaryEntity.toCompany?.idCompany = self.sessionConfig.companyId
        } else {
            let newSubsidiaryEntity = Tb_Subsidiary(context: self.mainContext)
            newSubsidiaryEntity.idSubsidiary = subsidiary.id
            newSubsidiaryEntity.name = subsidiary.name
            newSubsidiaryEntity.toImageUrl = image
            newSubsidiaryEntity.toCompany?.idCompany = self.sessionConfig.companyId
        }
        try saveData()
    }
    func sync(backgroundContext: NSManagedObjectContext, subsidiariesDTOs: [SubsidiaryClientDTO]) throws {
        for subsidiaryDTO in subsidiariesDTOs {
            guard self.sessionConfig.companyId == subsidiaryDTO.companyID else {
                rollback(context: backgroundContext)
                let cusError: String = "\(className): La compañia no es la misma"
                throw LocalStorageError.syncFailed(cusError)
            }
            guard let companyEntity = try self.sessionConfig.getCompanyEntityById(context: backgroundContext, companyId: subsidiaryDTO.companyID) else {
                rollback(context: backgroundContext)
                let cusError: String = "\(className): No se pudo obtener la compañia de la BD"
                throw LocalStorageError.syncFailed(cusError)
            }
            if let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityById(context: backgroundContext, subsidiaryId: subsidiaryDTO.id) {
                guard !subsidiaryDTO.isEquals(to: subsidiaryEntity) else {
                    print("\(className) No se actualiza, es lo mismo")
                    continue
                }
                subsidiaryEntity.name = subsidiaryDTO.name
                subsidiaryEntity.toImageUrl = try self.imageService.getImageEntityById(context: backgroundContext, imageId: subsidiaryDTO.imageUrlId)
                subsidiaryEntity.syncToken = subsidiaryDTO.syncToken
                subsidiaryEntity.createdAt = subsidiaryDTO.createdAt
                subsidiaryEntity.updatedAt = subsidiaryDTO.updatedAt
                try saveData(context: backgroundContext)
            } else {
                let newSubsidiaryEntity = Tb_Subsidiary(context: backgroundContext)
                newSubsidiaryEntity.idSubsidiary = subsidiaryDTO.id
                newSubsidiaryEntity.name = subsidiaryDTO.name
                newSubsidiaryEntity.syncToken = subsidiaryDTO.syncToken
                newSubsidiaryEntity.toImageUrl = try self.imageService.getImageEntityById(context: backgroundContext, imageId: subsidiaryDTO.imageUrlId)
                newSubsidiaryEntity.toCompany = companyEntity
                newSubsidiaryEntity.createdAt = subsidiaryDTO.createdAt
                newSubsidiaryEntity.updatedAt = subsidiaryDTO.updatedAt
                try saveData(context: backgroundContext)
            }
        }
    }
    func getSubsidiaries() -> [Subsidiary] {
        let filterAtt = NSPredicate(format: "toCompany.idCompany == %@", self.sessionConfig.companyId.uuidString)
        let request: NSFetchRequest<Tb_Subsidiary> = Tb_Subsidiary.fetchRequest()
        request.predicate = filterAtt
        do {
            let result = try self.mainContext.fetch(request)
            return result.compactMap {$0.toSubsidiary()}
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
