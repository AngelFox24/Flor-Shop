//
//  LocalProductManager.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 21/05/23.
//

import Foundation
import CoreData

protocol LocalProductManager {
    func save(product: Product) throws
    func sync(backgroundContext: NSManagedObjectContext, productsDTOs: [ProductDTO]) throws
    func getProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) -> [Product]
    func getLastUpdated() -> Date
}

class LocalProductManagerImpl: LocalProductManager {
    let sessionConfig: SessionConfig
    let mainContext: NSManagedObjectContext
    let className = "LocalProductManager"
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
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        let predicate = NSPredicate(format: "toSubsidiary.idSubsidiary == %@ AND updatedAt != nil", self.sessionConfig.subsidiaryId.uuidString)
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
    func getProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) -> [Product] {
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        request.fetchLimit = pageSize
        request.fetchOffset = (page - 1) * pageSize
        
        var predicate1 = NSPredicate(format: "toSubsidiary.idSubsidiary == %@", self.sessionConfig.subsidiaryId.uuidString)
        if seachText != "" {
            predicate1 = NSPredicate(format: "productName CONTAINS[c] %@ AND toSubsidiary.idSubsidiary == %@", seachText, self.sessionConfig.subsidiaryId.uuidString)
        }
        let predicate2 = getFilterAtribute(filter: filterAttribute)
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicate1, predicate2])
        
        request.predicate = compoundPredicate
        let sortDescriptor = getOrderFilter(order: primaryOrder)
        request.sortDescriptors = [sortDescriptor]
        do {
            return try self.mainContext.fetch(request).compactMap{$0.toProduct()}
        } catch {
            print("Error fetching. \(error)")
            return []
        }
    }
    func save(product: Product) throws {
        guard product.name != "" else {
            print("El nombre del producto no puede ser vacio")
            rollback()
            throw LocalStorageError.invalidInput("El nombre del producto no puede ser vacio")
        }
        guard let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityById(context: self.mainContext, subsidiaryId: self.sessionConfig.subsidiaryId) else {
            print("No se pudo obtener la subsidiaria")
            rollback()
            throw LocalStorageError.entityNotFound("No se pudo obtener la subsidiaria")
        }
        if let productEntity = try self.sessionConfig.getProductEntityById(context: self.mainContext, productId: product.id) {
            if productEntity.productName != product.name {
                guard !productNameExist(name: product.name, subsidiary: subsidiaryEntity) else {
                    print("El nombre del producto ya existe en otro producto")
                    rollback()
                    throw BusinessLogicError.duplicateProductName("El nombre del producto ya existe en otro producto")
                }
                productEntity.productName = product.name
            }
            if productEntity.barCode != product.barCode {
                guard !productBarCodeExist(barcode: product.barCode ?? "", subsidiary: subsidiaryEntity) else {
                    print("El codigo de barras ya existe en otro producto")
                    rollback()
                    throw BusinessLogicError.duplicateBarCode("El codigo de barras ya existe en otro producto")
                }
                productEntity.barCode = product.barCode
            }
            productEntity.active = product.active
            productEntity.quantityStock = Int64(product.qty)
            productEntity.unitCost = Int64(product.unitCost.cents)
            productEntity.expirationDate = product.expirationDate
            productEntity.unitPrice = Int64(product.unitPrice.cents)
            if let imageId = product.image?.id  {
                productEntity.toImageUrl = try self.sessionConfig.getImageEntityById(context: self.mainContext, imageId: imageId)
            }
            productEntity.createdAt = product.createdAt
            productEntity.updatedAt = product.updatedAt
            try saveData()
        } else {
            guard !productNameExist(name: product.name, subsidiary: subsidiaryEntity) else {
                print("El nombre del producto ya existe en otro producto")
                rollback()
                throw BusinessLogicError.duplicateProductName("El nombre del producto ya existe en otro producto")
            }
            guard !productBarCodeExist(barcode: product.barCode ?? "", subsidiary: subsidiaryEntity) else {
                print("El codigo de barras ya existe en otro producto")
                rollback()
                throw BusinessLogicError.duplicateBarCode("El codigo de barras ya existe en otro producto")
            }
            let newProductEntity = Tb_Product(context: mainContext)
            newProductEntity.idProduct = product.id
            newProductEntity.productName = product.name
            newProductEntity.active = product.active
            newProductEntity.quantityStock = Int64(product.qty)
            newProductEntity.unitCost = Int64(product.unitCost.cents)
            newProductEntity.barCode = product.barCode
            newProductEntity.unitPrice = Int64(product.unitPrice.cents)
            newProductEntity.expirationDate = product.expirationDate
            newProductEntity.toSubsidiary = subsidiaryEntity
            if let imageId = product.image?.id {
                newProductEntity.toImageUrl = try self.sessionConfig.getImageEntityById(context: self.mainContext, imageId: imageId)
            }
            newProductEntity.createdAt = product.createdAt
            newProductEntity.updatedAt = product.updatedAt
            try saveData()
        }
    }
    func sync(backgroundContext: NSManagedObjectContext, productsDTOs: [ProductDTO]) throws {
        for productDTO in productsDTOs {
            guard self.sessionConfig.subsidiaryId == productDTO.subsidiaryId else {
                print("Error en la sincronizacion, la subsidiaria no es la misma")
                rollback(context: backgroundContext)
                throw LocalStorageError.syncFailed("Error en la sincronizacion, la subsidiaria no es la misma")
            }
            guard let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityById(context: backgroundContext, subsidiaryId: productDTO.subsidiaryId) else {
                print("No se pudo obtener la subsidiaria")
                rollback(context: backgroundContext)
                throw LocalStorageError.entityNotFound("No se pudo obtener la subsidiaria")
            }
            if let productEntity = try self.sessionConfig.getProductEntityById(context: backgroundContext, productId: productDTO.id) {
                productEntity.productName = productDTO.productName
                productEntity.active = productDTO.active
                productEntity.quantityStock = Int64(productDTO.quantityStock)
                productEntity.barCode = productDTO.barCode
                productEntity.unitCost = Int64(productDTO.unitCost)
                productEntity.expirationDate = productDTO.expirationDate
                productEntity.unitPrice = Int64(productDTO.unitPrice)
                productEntity.createdAt = productDTO.createdAt.internetDateTime()
                productEntity.updatedAt = productDTO.updatedAt.internetDateTime()
                if let imageId = productDTO.imageUrlId {
                    productEntity.toImageUrl = try self.sessionConfig.getImageEntityById(context: backgroundContext, imageId: imageId)
                }
                try saveData(context: backgroundContext)
            } else {
                let productEntity = Tb_Product(context: backgroundContext)
                productEntity.idProduct = productDTO.id
                productEntity.toSubsidiary = subsidiaryEntity
                productEntity.productName = productDTO.productName
                productEntity.active = productDTO.active
                productEntity.quantityStock = Int64(productDTO.quantityStock)
                productEntity.barCode = productDTO.barCode
                productEntity.unitCost = Int64(productDTO.unitCost)
                productEntity.expirationDate = productDTO.expirationDate
                productEntity.unitPrice = Int64(productDTO.unitPrice)
                productEntity.createdAt = productDTO.createdAt.internetDateTime()
                productEntity.updatedAt = productDTO.updatedAt.internetDateTime()
                if let imageId = productDTO.imageUrlId {
                    productEntity.toImageUrl = try self.sessionConfig.getImageEntityById(context: backgroundContext, imageId: imageId)
                }
                try saveData(context: backgroundContext)
            }
        }
    }
    //MARK: Private Functions
    private func productNameExist(name: String, subsidiary: Tb_Subsidiary) -> Bool {
        guard name != "" else {
            print("Producto existe vacio aunque no exista xd")
            return true
        }
        let filterAtt = NSPredicate(format: "name == %@ AND toSubsidiary == %@", name, subsidiary)
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        request.predicate = filterAtt
        request.fetchLimit = 1
        do {
            let total = try self.mainContext.fetch(request).count
            return total == 0 ? false : true
        } catch let error {
            print("Error fetching. \(error)")
            return false
        }
    }
    private func productBarCodeExist(barcode: String, subsidiary: Tb_Subsidiary) -> Bool {
        guard barcode != "" else {
            print("Producto barcode vacio aunque no exista xd")
            return false
        }
        let filterAtt = NSPredicate(format: "barCode == %@ AND toSubsidiary == %@", barcode, subsidiary)
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        request.predicate = filterAtt
        request.fetchLimit = 1
        do {
            let total = try self.mainContext.fetch(request).count
            return total == 0 ? false : true
        } catch let error {
            print("Error fetching. \(error)")
            return false
        }
    }
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
    private func getOrderFilter(order: PrimaryOrder) -> NSSortDescriptor {
        var sortDescriptor = NSSortDescriptor(key: "productName", ascending: true)
        switch order {
        case .nameAsc:
            sortDescriptor = NSSortDescriptor(key: "productName", ascending: true)
        case .nameDesc:
            sortDescriptor = NSSortDescriptor(key: "productName", ascending: false)
        case .priceAsc:
            sortDescriptor = NSSortDescriptor(key: "unitPrice", ascending: true)
        case .priceDesc:
            sortDescriptor = NSSortDescriptor(key: "unitPrice", ascending: false)
        case .quantityAsc:
            sortDescriptor = NSSortDescriptor(key: "quantityStock", ascending: true)
        case .quantityDesc:
            sortDescriptor = NSSortDescriptor(key: "quantityStock", ascending: false)
        }
        return sortDescriptor
    }
    private func getFilterAtribute(filter: ProductsFilterAttributes) -> NSPredicate {
        var filterAtt = NSPredicate(format: "quantityStock != 0")
        switch filter {
        case .allProducts:
            filterAtt = NSPredicate(format: "quantityStock != 0 AND active == true")
        case .outOfStock:
            filterAtt = NSPredicate(format: "quantityStock == 0")
        case .productWithdrawn:
            filterAtt = NSPredicate(format: "active == false")
        }
        return filterAtt
    }
}
