//
//  LocalProductManager.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 21/05/23.
//

import Foundation
import CoreData

protocol ProductManager {
    func saveProduct(product: Product) throws -> String
    func sync(products: [Product]) throws
    func getListProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) throws -> [Product]
    //func filterProducts(word: String) -> [Product]
//    func setDefaultSubsidiary(subsidiary: Subsidiary)
//    func getDefaultSubsidiary() -> Subsidiary?
    func getLastUpdated() throws -> Date?
//    func releaseResourses()
}

class LocalProductManager: ProductManager {
//    var mainSubsidiaryEntity: Tb_Subsidiary?
    let sessionConfig: SessionConfig
    let mainContext: NSManagedObjectContext
    init(
        mainContext: NSManagedObjectContext,
        sessionConfig: SessionConfig
    ) {
        self.mainContext = mainContext
        self.sessionConfig = sessionConfig
    }
    func saveData () {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en ProductRepositoryImpl \(error)")
        }
    }
    func rollback() {
        self.mainContext.rollback()
    }
//    func releaseResourses() {
//        self.mainSubsidiaryEntity = nil
//    }
    func getLastUpdated() throws -> Date? {
        let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntity(context: self.mainContext)
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 1999, month: 1, day: 1)
        let dateFrom = calendar.date(from: components)
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        let predicate = NSPredicate(format: "toSubsidiary == %@ AND updatedAt != nil", subsidiaryEntity)
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
    func getListProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) throws -> [Product] {
        let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntity(context: self.mainContext)
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        request.fetchLimit = pageSize
        request.fetchOffset = (page - 1) * pageSize
        
        var predicate1 = NSPredicate(format: "toSubsidiary == %@", subsidiaryEntity)
        if seachText != "" {
            predicate1 = NSPredicate(format: "productName CONTAINS[c] %@ AND toSubsidiary == %@", seachText, subsidiaryEntity)
        }
        let predicate2 = getFilterAtribute(filter: filterAttribute)
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicate1, predicate2])
        
        request.predicate = compoundPredicate
        let sortDescriptor = getOrderFilter(order: primaryOrder)
        request.sortDescriptors = [sortDescriptor]
        let productList = try self.mainContext.fetch(request).map{$0.toProduct()}
        return productList
    }
    func saveProduct(product: Product) throws -> String {
        let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntity(context: self.mainContext)
        if let productInContext = product.toProductEntity(context: mainContext) { //Existe este producto, vamos a actualizarlo
            print("Se encontro producto, lo vamos a actualizar")
            productInContext.productName = product.name
            productInContext.active = product.active
            print("Active: \(product.active)")
            productInContext.quantityStock = Int64(product.qty)
            productInContext.barCode = product.barCode
            productInContext.unitCost = Int64(product.unitCost.cents)
            productInContext.expirationDate = product.expirationDate
            productInContext.unitPrice = Int64(product.unitPrice.cents)
            productInContext.createdAt = product.createdAt
            productInContext.updatedAt = product.updatedAt
            print("Guardado de Tiempo: \(product.updatedAt.description)")
            if let imageNN = product.image {
                if let imageEntity = product.image?.toImageUrlEntity(context: self.mainContext) { //Comprobamos si la imagen o la URL existe para asignarle el mismo
                    productInContext.toImageUrl = imageEntity
                } else {
                    let newImage = Tb_ImageUrl(context: self.mainContext)
                    newImage.idImageUrl = imageNN.id
                    newImage.imageUrl = imageNN.imageUrl
                    newImage.imageHash = imageNN.imageHash
                    productInContext.toImageUrl = newImage
                }
            }
            //productInContext.toImageUrl = product.image?.toImageUrlEntity(context: self.mainContext)
            saveData()
            return "Success"
        } else {
            //Buscar el nombre del producto con el mismo nombre en la sucursal
            if try !existProductInSubsidiary(product: product) {
                print("No se encontro producto, lo vamos a crear")
                //Creamos un nuevo producto
                let newProduct = Tb_Product(context: mainContext)
                newProduct.idProduct = product.id
                newProduct.productName = product.name
                newProduct.active = product.active
                print("Active: \(product.active)")
                newProduct.quantityStock = Int64(product.qty)
                newProduct.unitCost = Int64(product.unitCost.cents)
                newProduct.barCode = product.barCode
                newProduct.unitPrice = Int64(product.unitPrice.cents)
                newProduct.expirationDate = product.expirationDate
                newProduct.toSubsidiary = subsidiaryEntity
                newProduct.createdAt = product.createdAt
                newProduct.updatedAt = product.updatedAt
                print("Guardado de Tiempo: \(product.updatedAt.description)")
                if let imageNN = product.image {
                    if let imageEntity = product.image?.toImageUrlEntity(context: self.mainContext) { //Comprobamos si la imagen o la URL existe para asignarle el mismo
                        newProduct.toImageUrl = imageEntity
                    } else {
                        let newImage = Tb_ImageUrl(context: self.mainContext)
                        newImage.idImageUrl = imageNN.id
                        newImage.imageUrl = imageNN.imageUrl
                        newImage.imageHash = imageNN.imageHash
                        newProduct.toImageUrl = newImage
                    }
                }
                //newProduct.toImageUrl = product.image?.toImageUrlEntity(context: self.mainContext)
                saveData()
                return "Success"
            } else {
                print("Se encontro duplicados del nombre del producto")
                return "Se encontro duplicados del nombre del producto"
            }
        }
    }
    func getProductById(productId: UUID) -> Tb_Product? {
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        let predicate = NSPredicate(format: "idProduct == %@", productId.uuidString)
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
    func getImageById(imageId: UUID) -> Tb_ImageUrl? {
        let request: NSFetchRequest<Tb_ImageUrl> = Tb_ImageUrl.fetchRequest()
        let predicate = NSPredicate(format: "idImageUrl == %@", imageId.uuidString)
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
    func createImage(image: ImageUrl) throws -> Tb_ImageUrl {
        if let imageEntity = getImageById(imageId: image.id) { //Comprobamos si la imagen o la URL existe para asignarle el mismo
            imageEntity.imageUrl = image.imageUrl
            imageEntity.imageHash = image.imageHash
            imageEntity.createdAt = image.createdAt
            imageEntity.updatedAt = image.updatedAt
            return imageEntity
        } else {
            let imageEntity = Tb_ImageUrl(context: self.mainContext)
            imageEntity.idImageUrl = image.id
            imageEntity.imageUrl = image.imageUrl
            imageEntity.imageHash = image.imageHash
            imageEntity.createdAt = image.createdAt
            imageEntity.updatedAt = image.updatedAt
            return imageEntity
        }
    }
    func sync(products: [Product]) throws {
        let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntity(context: self.mainContext)
        for product in products {
            let imageEntity = product.image == nil ? nil : try createImage(image: product.image!)
            if let productEntity = getProductById(productId: product.id) {
                productEntity.productName = product.name
                productEntity.active = product.active
                productEntity.quantityStock = Int64(product.qty)
                productEntity.barCode = product.barCode
                productEntity.unitCost = Int64(product.unitCost.cents)
                productEntity.expirationDate = product.expirationDate
                productEntity.unitPrice = Int64(product.unitPrice.cents)
                productEntity.createdAt = product.createdAt
                productEntity.updatedAt = product.updatedAt
                productEntity.toImageUrl = imageEntity
                productEntity.toSubsidiary = subsidiaryEntity
            } else {
                let productEntity = Tb_Product(context: self.mainContext)
                productEntity.productName = product.name
                productEntity.active = product.active
                productEntity.quantityStock = Int64(product.qty)
                productEntity.barCode = product.barCode
                productEntity.unitCost = Int64(product.unitCost.cents)
                productEntity.expirationDate = product.expirationDate
                productEntity.unitPrice = Int64(product.unitPrice.cents)
                productEntity.createdAt = product.createdAt
                productEntity.updatedAt = product.updatedAt
                productEntity.toImageUrl = imageEntity
                productEntity.toSubsidiary = subsidiaryEntity
            }
        }
        saveData()
    }
    func existProductInSubsidiary(product: Product) throws -> Bool {
        let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntity(context: self.mainContext)
        let filterAtt = NSPredicate(format: "productName == %@ AND toSubsidiary == %@", product.name, subsidiaryEntity)
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        request.predicate = filterAtt
        let quantityDuplicate = try self.mainContext.fetch(request).count
        print("Cantidad de Duplicados: \(quantityDuplicate)")
        return quantityDuplicate == 0 ? false : true
    }
    func getOrderFilter(order: PrimaryOrder) -> NSSortDescriptor {
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
    func getFilterAtribute(filter: ProductsFilterAttributes) -> NSPredicate {
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
