//
//  LocalSubsidiaryManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol LocalSubsidiaryManager {
    func sync(backgroundContext: NSManagedObjectContext, subsidiariesDTOs: [SubsidiaryDTO]) throws
    func save(subsidiary: Subsidiary) throws
    func getLastUpdated() -> Date
    func getSubsidiaries() -> [Subsidiary]
}

class LocalSubsidiaryManagerImpl: LocalSubsidiaryManager {
    let sessionConfig: SessionConfig
    let mainContext: NSManagedObjectContext
    let className = "LocalSubsidiaryManager"
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
        if let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityById(context: self.mainContext, subsidiaryId: subsidiary.id) {
            subsidiaryEntity.idSubsidiary = subsidiary.id
            subsidiaryEntity.name = subsidiary.name
            subsidiaryEntity.toImageUrl = subsidiary.image?.toImageUrlEntity(context: self.mainContext)
            subsidiaryEntity.toCompany?.idCompany = self.sessionConfig.companyId
        } else {
            let newSubsidiaryEntity = Tb_Subsidiary(context: self.mainContext)
            newSubsidiaryEntity.idSubsidiary = subsidiary.id
            newSubsidiaryEntity.name = subsidiary.name
            newSubsidiaryEntity.toImageUrl = subsidiary.image?.toImageUrlEntity(context: self.mainContext)
            newSubsidiaryEntity.toCompany?.idCompany = self.sessionConfig.companyId
        }
        try saveData()
    }
    func sync(backgroundContext: NSManagedObjectContext, subsidiariesDTOs: [SubsidiaryDTO]) throws {
//        print("Local Sync: se sincronizara la subsidiaria")
        for subsidiaryDTO in subsidiariesDTOs {
            guard self.sessionConfig.companyId == subsidiaryDTO.companyID else {
                print("La compañia no es la misma")
                rollback(context: backgroundContext)
                let cusError: String = "\(className): La compañia no es la misma"
                throw LocalStorageError.syncFailed(cusError)
            }
            guard let companyEntity = try self.sessionConfig.getCompanyEntityById(context: backgroundContext, companyId: subsidiaryDTO.companyID) else {
                print("No se pudo obtener la compañia: \(subsidiaryDTO.companyID)")
                rollback(context: backgroundContext)
                let cusError: String = "\(className): No se pudo obtener la compañia de la BD"
                throw LocalStorageError.syncFailed(cusError)
            }
            if let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityById(context: backgroundContext, subsidiaryId: subsidiaryDTO.id) {
                subsidiaryEntity.name = subsidiaryDTO.name
                if let imageId = subsidiaryDTO.imageUrlId {
                    subsidiaryEntity.toImageUrl = try self.sessionConfig.getImageEntityById(context: backgroundContext, imageId: imageId)
                }
                subsidiaryEntity.createdAt = subsidiaryDTO.createdAt.internetDateTime()
                subsidiaryEntity.updatedAt = subsidiaryDTO.updatedAt.internetDateTime()
                try saveData(context: backgroundContext)
            } else {
                let newSubsidiaryEntity = Tb_Subsidiary(context: backgroundContext)
                newSubsidiaryEntity.idSubsidiary = subsidiaryDTO.id
                newSubsidiaryEntity.name = subsidiaryDTO.name
                if let imageId = subsidiaryDTO.imageUrlId {
                    newSubsidiaryEntity.toImageUrl = try self.sessionConfig.getImageEntityById(context: backgroundContext, imageId: imageId)
                }
                newSubsidiaryEntity.toCompany = companyEntity
                newSubsidiaryEntity.createdAt = subsidiaryDTO.createdAt.internetDateTime()
                newSubsidiaryEntity.updatedAt = subsidiaryDTO.updatedAt.internetDateTime()
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
