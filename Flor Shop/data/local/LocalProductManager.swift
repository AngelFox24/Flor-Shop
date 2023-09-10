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
    func getListProducts() -> [Product]
    func reduceStock(cartDetails: [CartDetail]) -> Bool
    func filterProducts(word: String) -> [Product]
    func setOrder(order: PrimaryOrder)
    func setFilter(filter: ProductsFilterAttributes)
    func setDefaultSubsidiary(subisidiary: Subsidiary)
    func getDefaultSubsidiary() -> Subsidiary?
}

class LocalProductManager: ProductManager {
    var primaryOrder: PrimaryOrder = .nameAsc
    var filterAttribute: ProductsFilterAttributes = .allProducts
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
    func getListProducts() -> [Product] {
        var productList: [Product] = []
        guard let subsidiary = self.mainSubsidiaryEntity else {
            print("No se encontró sucursal")
            return productList
        }
        let filterAtt = NSPredicate(format: "toSubsidiary == %@", subsidiary)
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        request.predicate = filterAtt
        let sortDescriptor = getOrderFilter()
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
    func reduceStock(cartDetails: [CartDetail]) -> Bool {
        var saveChanges: Bool = true
        for cartDetail in cartDetails {
            if let productEntity = cartDetail.product.toProductEntity(context: self.mainContext) {
                if productEntity.quantityStock >= Int64(cartDetail.quantity) {
                    productEntity.quantityStock -= Int64(cartDetail.quantity)
                } else {
                    saveChanges = false
                }
            } else {
                print("No se encontro producto para reduceStock")
                saveChanges = false
            }
        }
        if saveChanges {
            saveData()
        } else {
            print("Eliminamos los cambios en reduceStock")
            rollback()
        }
        return saveChanges
    }
    func filterProducts(word: String) -> [Product] {
        var products: [Product] = []
        guard let subsidiaryEntity: Tb_Subsidiary = self.mainSubsidiaryEntity else {
            print("No se encontró sucursal")
            return products
        }
        let fetchRequest: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        let predicate1 = NSPredicate(format: "productName CONTAINS[c] %@ AND toSubsidiary == %@", word, subsidiaryEntity)
        let predicate2 = getFilterAtribute()
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicate1, predicate2])
        fetchRequest.predicate = compoundPredicate
        // Agregar el sort descriptor para ordenar por nombre ascendente
        let sortDescriptor = getOrderFilter()
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            // Ejecutar la consulta y obtener los resultados
            let productosBD = try self.mainContext.fetch(fetchRequest)
            products = productosBD.mapToListProduct()
            return products
        } catch {
            print("Error al ejecutar la consulta: \(error.localizedDescription)")
            return products
        }
    }
    func setOrder(order: PrimaryOrder) {
        self.primaryOrder = order
    }
    func setFilter(filter: ProductsFilterAttributes) {
        self.filterAttribute = filter
    }
    func setDefaultSubsidiary(subisidiary: Subsidiary) {
        guard let subsidiaryEntity: Tb_Subsidiary = subisidiary.toSubsidiaryEntity(context: self.mainContext) else {
            print("No se pudo asingar sucursar default")
            return
        }
        self.mainSubsidiaryEntity = subsidiaryEntity
    }
    func getOrderFilter() -> NSSortDescriptor {
        var sortDescriptor = NSSortDescriptor(key: "productName", ascending: true)
        switch primaryOrder {
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
    func getFilterAtribute() -> NSPredicate {
        var filterAtt = NSPredicate(format: "quantityStock != 0")
        switch filterAttribute {
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
