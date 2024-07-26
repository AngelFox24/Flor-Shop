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
    func addSubsidiary(subsidiary: Subsidiary)
    func getLastUpdated() throws -> Date?
    func getSubsidiaries() -> [Subsidiary]
    func updateSubsidiary(subsidiary: Subsidiary)
    func deleteSubsidiary(subsidiary: Subsidiary)
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
    func saveData() {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en LocalEmployeeManager: \(error)")
        }
    }
    func rollback() {
        self.mainContext.rollback()
    }
    func getLastUpdated() throws -> Date? {
//        let companyEntity = try self.sessionConfig.getCompanyEntity(context: self.mainContext)
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 1999, month: 1, day: 1)
        let dateFrom = calendar.date(from: components)
        let request: NSFetchRequest<Tb_Subsidiary> = Tb_Subsidiary.fetchRequest()
        let predicate = NSPredicate(format: "toCompany.idCompany == %@ AND updatedAt != nil", self.sessionConfig.companyId.uuidString)
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
    //C - Create
    func addSubsidiary(subsidiary: Subsidiary) {
        if let subsidiaryEntity = getSubsidiaryById(subsidiaryId: subsidiary.id) {
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
    func getSubsidiaryById(subsidiaryId: UUID) -> Tb_Subsidiary? {
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
    func sync(subsidiariesDTOs: [SubsidiaryDTO]) throws {
        for subsidiaryDTO in subsidiariesDTOs {
            guard self.sessionConfig.companyId == subsidiaryDTO.companyID else {
                throw LocalStorageError.notFound("La compañia no es la misma")
            }
            if let subsidiaryEntity = getSubsidiaryById(subsidiaryId: subsidiaryDTO.id) {
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
    //R - Read
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
    //U - Update
    func updateSubsidiary(subsidiary: Subsidiary) {
        
    }
    //D - Delete
    func deleteSubsidiary(subsidiary: Subsidiary) {
        
    }
}
