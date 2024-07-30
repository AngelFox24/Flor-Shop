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
        if let subsidiaryEntity = getSubsidiaryEntityById(subsidiaryId: subsidiary.id) {
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
        for subsidiaryDTO in subsidiariesDTOs {
            guard self.sessionConfig.companyId == subsidiaryDTO.companyID else {
                throw LocalStorageError.notFound("La compañia no es la misma")
            }
            if let subsidiaryEntity = getSubsidiaryEntityById(subsidiaryId: subsidiaryDTO.id) {
                subsidiaryEntity.name = subsidiaryDTO.name
                subsidiaryEntity.toImageUrl?.idImageUrl = subsidiaryDTO.imageUrl?.id
                subsidiaryEntity.toCompany?.idCompany = subsidiaryDTO.companyID
                subsidiaryEntity.createdAt = subsidiaryDTO.createdAt.internetDateTime()
                subsidiaryEntity.updatedAt = subsidiaryDTO.updatedAt.internetDateTime()
            } else {
                let newSubsidiaryEntity = Tb_Subsidiary(context: self.mainContext)
                newSubsidiaryEntity.idSubsidiary = subsidiaryDTO.id
                newSubsidiaryEntity.name = subsidiaryDTO.name
                newSubsidiaryEntity.toImageUrl?.idImageUrl = subsidiaryDTO.imageUrl?.id
                newSubsidiaryEntity.toCompany?.idCompany = subsidiaryDTO.companyID
                newSubsidiaryEntity.createdAt = subsidiaryDTO.createdAt.internetDateTime()
                newSubsidiaryEntity.updatedAt = subsidiaryDTO.updatedAt.internetDateTime()
            }
        }
        saveData()
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
            print("Error al guardar en LocalEmployeeManager: \(error)")
        }
    }
    private func rollback() {
        self.mainContext.rollback()
    }
    private func getSubsidiaryEntityById(subsidiaryId: UUID) -> Tb_Subsidiary? {
        let request: NSFetchRequest<Tb_Subsidiary> = Tb_Subsidiary.fetchRequest()
        let predicate = NSPredicate(format: "toCompany.idCompany == %@", self.sessionConfig.companyId.uuidString)
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
