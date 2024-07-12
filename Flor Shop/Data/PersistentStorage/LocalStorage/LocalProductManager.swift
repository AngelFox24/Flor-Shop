//
//  LocalProductManager.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 21/05/23.
//

import Foundation
import CoreData

protocol ProductManager {
    func saveProduct(product: Product) -> String
    func getListProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) -> [Product]
    //func filterProducts(word: String) -> [Product]
    func setDefaultSubsidiary(subsidiary: Subsidiary)
    func getDefaultSubsidiary() -> Subsidiary?
    func getLastUpdated() -> Date?
    func releaseResourses()
}

class LocalProductManager: ProductManager {
    var mainSubsidiaryEntity: Tb_Subsidiary?
    let mainContext: NSManagedObjectContext
    init(mainContext: NSManagedObjectContext) {
        self.mainContext = mainContext
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
    func releaseResourses() {
        self.mainSubsidiaryEntity = nil
    }
    func getLastUpdated() -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 2024, month: 7, day: 12)
        let dateFrom = calendar.date(from: components)
        var listDate: [Date?] = []
        guard let subsidiaryEntity = self.mainSubsidiaryEntity else {
            print("No se encontró sucursal")
            return dateFrom
        }
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        let predicate = NSPredicate(format: "toSubsidiary == %@ AND updatedAt != nil", subsidiaryEntity)
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            listDate = try self.mainContext.fetch(request).map{$0.updatedAt}
        } catch let error {
            print("Error fetching. \(error)")
        }
        guard let last = listDate[0] else {
            print("Se retorna valor por defecto")
            return dateFrom
        }
        print("Se retorna valor desde la BD")
        return last
    }
    func getListProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) -> [Product] {
        var productList: [Product] = []
        guard let subsidiaryEntity = self.mainSubsidiaryEntity else {
            print("No se encontró sucursal")
            return productList
        }
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
        do {
            productList = try self.mainContext.fetch(request).map{$0.toProduct()}
        } catch let error {
            print("Error fetching. \(error)")
        }
        return productList
    }
    func saveProduct(product: Product) -> String {
        guard let subsidiaryEntity = self.mainSubsidiaryEntity else {
            print("No se encontró sucursal")
            return "No se encontró sucursal"
        }
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
            if !existProductInSubsidiary(product: product) {
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
    func existProductInSubsidiary(product: Product) -> Bool {
        guard let subsidiary = self.mainSubsidiaryEntity else {
            print("No se encontró sucursal")
            return true
        }
        let filterAtt = NSPredicate(format: "productName == %@ AND toSubsidiary == %@", product.name, subsidiary)
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        request.predicate = filterAtt
        do {
            let quantityDuplicate = try self.mainContext.fetch(request).count
            print("Cantidad de Duplicados: \(quantityDuplicate)")
            return quantityDuplicate == 0 ? false : true
        } catch let error {
            print("Error fetching. \(error)")
            return false
        }
    }
    func setDefaultSubsidiary(subsidiary: Subsidiary) {
        guard let subsidiaryEntity: Tb_Subsidiary = subsidiary.toSubsidiaryEntity(context: self.mainContext) else {
            print("No se pudo asingar sucursar default")
            return
        }
        self.mainSubsidiaryEntity = subsidiaryEntity
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
    func getDefaultSubsidiary() -> Subsidiary? {
        return self.mainSubsidiaryEntity?.toSubsidiary()
    }
}
