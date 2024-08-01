//
//  LocalSubsidiaryManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol LocalSubsidiaryManager {
    func sync(subsidiariesDTOs: [SubsidiaryDTO]) throws
    func save(subsidiary: Subsidiary)
    func getLastUpdated() -> Date
    func getSubsidiaries() -> [Subsidiary]
}

class LocalSubsidiaryManagerImpl: LocalSubsidiaryManager {
    let sessionConfig: SessionConfig
    let mainContext: NSManagedObjectContext
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
    func save(subsidiary: Subsidiary) {
        if let subsidiaryEntity = self.sessionConfig.getSubsidiaryEntityById(context: self.mainContext, subsidiaryId: subsidiary.id) {
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
        saveData()
    }
    func sync(subsidiariesDTOs: [SubsidiaryDTO]) throws {
        print("Local Sync: se sincronizara la subsidiaria")
        for subsidiaryDTO in subsidiariesDTOs {
            guard self.sessionConfig.companyId == subsidiaryDTO.companyID else {
                print("La compañia no es la misma")
                rollback()
                throw LocalStorageError.notFound("La compañia no es la misma")
            }
            guard let companyEntity = self.sessionConfig.getCompanyEntityById(context: self.mainContext, companyId: subsidiaryDTO.companyID) else {
                print("No se pudo obtener la compañia: \(subsidiaryDTO.companyID)")
                rollback()
                throw LocalStorageError.notFound("No se pudo obtener la compañia")
            }
            if let subsidiaryEntity = self.sessionConfig.getSubsidiaryEntityById(context: self.mainContext, subsidiaryId: subsidiaryDTO.id) {
                subsidiaryEntity.name = subsidiaryDTO.name
                if let imageId = subsidiaryDTO.imageUrl?.id, let imageEntity = self.sessionConfig.getImageEntityById(context: self.mainContext, imageId: imageId) {
                    subsidiaryEntity.toImageUrl = imageEntity
                }
                subsidiaryEntity.toCompany = companyEntity
                subsidiaryEntity.createdAt = subsidiaryDTO.createdAt.internetDateTime()
                subsidiaryEntity.updatedAt = subsidiaryDTO.updatedAt.internetDateTime()
                print("Local Sync: Se guardara en LocalSubsidiaryManager")
                saveData()
            } else {
                let newSubsidiaryEntity = Tb_Subsidiary(context: self.mainContext)
                newSubsidiaryEntity.idSubsidiary = subsidiaryDTO.id
                newSubsidiaryEntity.name = subsidiaryDTO.name
                if let imageId = subsidiaryDTO.imageUrl?.id, let imageEntity = self.sessionConfig.getImageEntityById(context: self.mainContext, imageId: imageId) {
                    newSubsidiaryEntity.toImageUrl = imageEntity
                }
                newSubsidiaryEntity.toCompany = companyEntity
                newSubsidiaryEntity.createdAt = subsidiaryDTO.createdAt.internetDateTime()
                newSubsidiaryEntity.updatedAt = subsidiaryDTO.updatedAt.internetDateTime()
                print("Local Sync: Se guardara en LocalSubsidiaryManager")
                saveData()
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
    private func saveData() {
        do {
            try self.mainContext.save()
        } catch {
            rollback()
            print("Error al guardar en LocalSubsidiaryManager: \(error)")
        }
    }
    private func rollback() {
        self.mainContext.rollback()
    }
}
