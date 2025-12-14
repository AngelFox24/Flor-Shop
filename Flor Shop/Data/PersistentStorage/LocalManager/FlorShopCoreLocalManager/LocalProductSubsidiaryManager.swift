import Foundation
import CoreData
import FlorShopDTOs

protocol LocalProductSubsidiaryManager {
    func getLastToken() -> Int64
    func sync(backgroundContext: NSManagedObjectContext, productsSubsidiaryDTOs: [ProductSubsidiaryClientDTO]) throws
}

class LocalProductSubsidiaryManagerImpl: LocalProductSubsidiaryManager {
    let sessionConfig: SessionConfig
    let mainContext: NSManagedObjectContext
    let className = "[LocalProductSubsidiaryManager]"
    init(
        mainContext: NSManagedObjectContext,
        sessionConfig: SessionConfig
    ) {
        self.mainContext = mainContext
        self.sessionConfig = sessionConfig
    }
    func getLastToken() -> Int64 {
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        let predicate = NSPredicate(format: "toSubsidiary.subsidiaryCic == %@ AND syncToken != nil", self.sessionConfig.subsidiaryCic)
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
    func sync(backgroundContext: NSManagedObjectContext, productsSubsidiaryDTOs: [ProductSubsidiaryClientDTO]) throws {
        for productSubsidiaryDTO in productsSubsidiaryDTOs {
            guard self.sessionConfig.subsidiaryCic == productSubsidiaryDTO.subsidiaryCic else {
                print("Error en la sincronizacion, la subsidiaria no es la misma")
                rollback(context: backgroundContext)
                throw LocalStorageError.syncFailed("Error en la sincronizacion, la subsidiaria no es la misma")
            }
            if let productSubsidiaryEntity = try self.sessionConfig.getProductSubsidiaryEntityByCic(
                context: backgroundContext,
                productCic: productSubsidiaryDTO.productCic
            ) {
                guard !productSubsidiaryDTO.isEquals(to: productSubsidiaryEntity) else {
                    print("\(className) No se actualizo el productoSubsidiary porque es el mismo")
                    continue
                }
                productSubsidiaryEntity.active = productSubsidiaryDTO.active
                productSubsidiaryEntity.expirationDate = productSubsidiaryDTO.expirationDate
                productSubsidiaryEntity.quantityStock = Int64(productSubsidiaryDTO.quantityStock)
                productSubsidiaryEntity.unitCost = Int64(productSubsidiaryDTO.unitCost)
                productSubsidiaryEntity.unitPrice = Int64(productSubsidiaryDTO.unitPrice)
                productSubsidiaryEntity.syncToken = productSubsidiaryDTO.syncToken
                productSubsidiaryEntity.createdAt = productSubsidiaryDTO.createdAt
                productSubsidiaryEntity.updatedAt = productSubsidiaryDTO.updatedAt
                try saveData(context: backgroundContext)
                print("\(className) Se actualizo el producto")
            } else {
                guard let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityByCic(
                    context: backgroundContext,
                    subsidiaryCic: productSubsidiaryDTO.subsidiaryCic
                ) else {
                    print("No se pudo obtener la subsidiaria")
                    rollback(context: backgroundContext)
                    throw LocalStorageError.entityNotFound("No se pudo obtener la subsidiaria")
                }
                guard let productEntity = try self.sessionConfig.getProductEntityByCic(
                    context: backgroundContext,
                    productCic: productSubsidiaryDTO.productCic
                ) else {
                    rollback(context: backgroundContext)
                    let cusError: String = "\(className): El empleado no existe en la BD local"
                    throw LocalStorageError.syncFailed(cusError)
                }
                let newProductSubsidiaryEntity = Tb_ProductSubsidiary(context: backgroundContext)
                newProductSubsidiaryEntity.active = productSubsidiaryDTO.active
                newProductSubsidiaryEntity.active = productSubsidiaryDTO.active
                newProductSubsidiaryEntity.quantityStock = Int64(productSubsidiaryDTO.quantityStock)
                newProductSubsidiaryEntity.unitCost = Int64(productSubsidiaryDTO.unitCost)
                newProductSubsidiaryEntity.expirationDate = productSubsidiaryDTO.expirationDate
                newProductSubsidiaryEntity.unitPrice = Int64(productSubsidiaryDTO.unitPrice)
                newProductSubsidiaryEntity.syncToken = productSubsidiaryDTO.syncToken
                newProductSubsidiaryEntity.createdAt = productSubsidiaryDTO.createdAt
                newProductSubsidiaryEntity.updatedAt = productSubsidiaryDTO.updatedAt
                newProductSubsidiaryEntity.toProduct = productEntity
                newProductSubsidiaryEntity.toSubsidiary = subsidiaryEntity
                try saveData(context: backgroundContext)
                print("\(className) Se creo el producto")
            }
        }
    }
    //MARK: Private Functions
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
