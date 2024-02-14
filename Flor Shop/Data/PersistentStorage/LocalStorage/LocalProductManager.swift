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
    func getLastUpdated() -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 1990, month: 1, day: 1)
        let dateFrom = calendar.date(from: components)
        var listDate: [Date?] = []
        guard let subsidiaryEntity = self.mainSubsidiaryEntity else {
            print("No se encontró sucursal")
            return dateFrom
        }
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        let predicate = NSPredicate(format: "toSubsidiary == %@", subsidiaryEntity)
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            listDate = try self.mainContext.fetch(request).map{$0.updatedAt}
        } catch let error {
            print("Error fetching. \(error)")
        }
        guard let last = listDate[0] else {
            return dateFrom
        }
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
            productInContext.quantityStock = Int64(product.qty)
            productInContext.unitCost = product.unitCost
            productInContext.expirationDate = product.expirationDate
            productInContext.unitPrice = product.unitPrice
            productInContext.toImageUrl = product.image.toImageUrlEntity(context: self.mainContext)
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
                newProduct.quantityStock = Int64(product.qty)
                newProduct.unitCost = product.unitCost
                newProduct.unitPrice = product.unitPrice
                newProduct.expirationDate = product.expirationDate
                newProduct.toSubsidiary = subsidiaryEntity
                newProduct.toImageUrl = product.image.toImageUrlEntity(context: self.mainContext)
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
            filterAtt = NSPredicate(format: "quantityStock != 0")
        case .outOfStock:
            filterAtt = NSPredicate(format: "quantityStock == 0")
        case .productWithdrawn:
            filterAtt = NSPredicate(format: "quantityStock == 0")
        }
        return filterAtt
    }
    func getDefaultSubsidiary() -> Subsidiary? {
        return self.mainSubsidiaryEntity?.toSubsidiary()
    }
}
