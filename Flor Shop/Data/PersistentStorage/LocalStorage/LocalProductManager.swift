//
//  LocalProductManager.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 21/05/23.
//

import Foundation
import CoreData

protocol LocalProductManager {
    func saveProduct(product: Product)
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
    func saveProduct(product: Product) {
        if let productEntity = getProductById(productId: product.id) {
            productEntity.productName = product.name
            productEntity.active = product.active
            productEntity.quantityStock = Int64(product.qty)
            productEntity.barCode = product.barCode
            productEntity.unitCost = Int64(product.unitCost.cents)
            productEntity.expirationDate = product.expirationDate
            productEntity.unitPrice = Int64(product.unitPrice.cents)
            productEntity.toImageUrl?.idImageUrl = product.image?.id
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
            newProductEntity.toSubsidiary?.idSubsidiary = self.sessionConfig.subsidiaryId
            newProductEntity.toImageUrl?.idImageUrl = product.image?.id
            newProductEntity.createdAt = product.createdAt
            newProductEntity.updatedAt = product.updatedAt
            saveData()
        }
    }
    func sync(productsDTOs: [ProductDTO]) throws {
        for productDTO in productsDTOs {
            guard self.sessionConfig.subsidiaryId == productDTO.subsidiaryId else {
                throw LocalStorageError.notFound("Error en la sincronizacion, la subsidiaria no es la misma")
            }
            if let productEntity = getProductById(productId: productDTO.id) {
                productEntity.productName = productDTO.productName
                productEntity.active = productDTO.active
                productEntity.quantityStock = Int64(productDTO.quantityStock)
                productEntity.barCode = productDTO.barCode
                productEntity.unitCost = Int64(productDTO.unitCost)
                productEntity.expirationDate = productDTO.expirationDate
                productEntity.unitPrice = Int64(productDTO.unitPrice)
                productEntity.createdAt = productDTO.createdAt.internetDateTime()
                productEntity.updatedAt = productDTO.updatedAt.internetDateTime()
                productEntity.toImageUrl?.idImageUrl = productDTO.imageUrl?.id
                productEntity.toSubsidiary?.idSubsidiary = productDTO.subsidiaryId
            } else {
                let productEntity = Tb_Product(context: self.mainContext)
                productEntity.productName = productDTO.productName
                productEntity.active = productDTO.active
                productEntity.quantityStock = Int64(productDTO.quantityStock)
                productEntity.barCode = productDTO.barCode
                productEntity.unitCost = Int64(productDTO.unitCost)
                productEntity.expirationDate = productDTO.expirationDate
                productEntity.unitPrice = Int64(productDTO.unitPrice)
                productEntity.createdAt = productDTO.createdAt.internetDateTime()
                productEntity.updatedAt = productDTO.updatedAt.internetDateTime()
                productEntity.toImageUrl?.idImageUrl = productDTO.imageUrl?.id
                productEntity.toSubsidiary?.idSubsidiary = productDTO.subsidiaryId
            }
        }
        saveData()
    }
    func existProductInSubsidiary(product: Product) throws -> Bool {
        let filterAtt = NSPredicate(format: "productName == %@ AND toSubsidiary.idSubsidiary == %@", product.name, self.sessionConfig.subsidiaryId.uuidString)
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        request.predicate = filterAtt
        let quantityDuplicate = try self.mainContext.fetch(request).count
        print("Cantidad de Duplicados: \(quantityDuplicate)")
        return quantityDuplicate == 0 ? false : true
    }
    //MARK: Private Functions
    private func saveData () {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en ProductRepositoryImpl \(error)")
        }
    }
    private func rollback() {
        self.mainContext.rollback()
    }
    private func getProductById(productId: UUID) -> Tb_Product? {
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        let predicate = NSPredicate(format: "idProduct == %@ AND toSubsidiary.idSubsidiary == %@", productId.uuidString, self.sessionConfig.subsidiaryId.uuidString)
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
