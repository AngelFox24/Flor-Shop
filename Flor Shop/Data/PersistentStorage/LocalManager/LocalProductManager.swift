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
    func sync(productsDTOs: [ProductDTO]) throws
    func getProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) -> [Product]
    func getLastUpdated() -> Date
}

class LocalProductManagerImpl: LocalProductManager {
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
        guard let subsidiaryEntity = self.sessionConfig.getSubsidiaryEntityById(context: self.mainContext, subsidiaryId: self.sessionConfig.subsidiaryId) else {
            print("No se pudo obtener la subsidiaria")
            rollback()
            throw LocalStorageError.notFound("No se pudo obtener la subsidiaria")
        }
        if let productEntity = self.sessionConfig.getProductEntityById(context: self.mainContext, productId: product.id) {
            productEntity.productName = product.name
            productEntity.active = product.active
            productEntity.quantityStock = Int64(product.qty)
            productEntity.barCode = product.barCode
            productEntity.unitCost = Int64(product.unitCost.cents)
            productEntity.expirationDate = product.expirationDate
            productEntity.unitPrice = Int64(product.unitPrice.cents)
            if let imageId = product.image?.id, let imageEntity = self.sessionConfig.getImageEntityById(context: self.mainContext, imageId: imageId) {
                productEntity.toImageUrl = imageEntity
            }
            productEntity.createdAt = product.createdAt
            productEntity.updatedAt = product.updatedAt
            saveData()
        } else {
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
            if let imageId = product.image?.id, let imageEntity = self.sessionConfig.getImageEntityById(context: self.mainContext, imageId: imageId) {
                newProductEntity.toImageUrl = imageEntity
            }
            newProductEntity.createdAt = product.createdAt
            newProductEntity.updatedAt = product.updatedAt
            saveData()
        }
    }
    func sync(productsDTOs: [ProductDTO]) throws {
        for productDTO in productsDTOs {
            guard self.sessionConfig.subsidiaryId == productDTO.subsidiaryId else {
                print("Error en la sincronizacion, la subsidiaria no es la misma")
                rollback()
                throw LocalStorageError.notFound("Error en la sincronizacion, la subsidiaria no es la misma")
            }
            guard let subsidiaryEntity = self.sessionConfig.getSubsidiaryEntityById(context: self.mainContext, subsidiaryId: productDTO.subsidiaryId) else {
                print("No se pudo obtener la subsidiaria")
                rollback()
                throw LocalStorageError.notFound("No se pudo obtener la subsidiaria")
            }
            if let productEntity = self.sessionConfig.getProductEntityById(context: self.mainContext, productId: productDTO.id) {
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
                    productEntity.toImageUrl = self.sessionConfig.getImageEntityById(context: self.mainContext, imageId: imageId)
                }
//                productEntity.toSubsidiary = subsidiaryEntity
                saveData()
            } else {
                let productEntity = Tb_Product(context: self.mainContext)
                productEntity.idProduct = productDTO.id
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
                    productEntity.toImageUrl = self.sessionConfig.getImageEntityById(context: self.mainContext, imageId: imageId)
                }
                productEntity.toSubsidiary = subsidiaryEntity
                saveData()
            }
        }
    }
    //MARK: Private Functions
    private func saveData () {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en ProductRepositoryImpl \(error)")
            rollback()
        }
    }
    private func rollback() {
        self.mainContext.rollback()
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
