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
    func reduceStock() -> Bool
    func filterProducts(word: String) -> [Product]
    func setOrder(order: PrimaryOrder)
    func setFilter(filter: ProductsFilterAttributes)
}

class LocalProductManager: ProductManager {
    var primaryOrder: PrimaryOrder = .nameAsc
    var filterAttribute: ProductsFilterAttributes = .allProducts
    let mainContext: NSManagedObjectContext
    func getListProducts() -> [Product] {
        var productList: [Tb_Product] = []
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        let predicate = getFilterAtribute()
        request.predicate = predicate
        let sortDescriptor = getOrderFilter()
        request.sortDescriptors = [sortDescriptor]
        do {
            productList = try self.mainContext.fetch(request)
        } catch let error {
            print("Error fetching. \(error)")
        }
        return productList.mapToListProduct()
    }
    func saveProduct(product: Product) -> String {
        var message = ""
        if product.isProductNameValid(),
           product.isQuantityValid(),
           product.isUnitCostValid(),
           product.isUnitPriceValid(),
           product.isExpirationDateValid(),
           product.isURLValid() {
            if let productInContext = product.toProductEntity(context: mainContext) {
                productInContext.productName = product.name
                productInContext.quantityStock = product.qty
                productInContext.unitCost = product.unitCost
                productInContext.expirationDate = product.expirationDate
                productInContext.unitPrice = product.unitPrice
                // TODO: asignar imagen correctamente
                //productInContext.toImageUrl = product.url
            } else {
                _ = product.toNewProductEntity(context: mainContext)
            }
            saveData()
            message = "Success"
        } else {
            if !product.isProductNameValid() {
                message = "El nombre del producto esta mal \(product.name)"
            } else if !product.isUnitCostValid() {
                message = "El costo unitario esta mal \(product.unitCost)"
            } else if !product.isUnitPriceValid() {
                message = "El precio unitario esta mal \(product.unitPrice)"
            } else if !product.isExpirationDateValid() {
                message = "La fecha de vencimiento esta mal \(product.expirationDate)"
            } else if !product.isURLValid() {
                message = "La URL esta mal \(product.url)"
            }
        }
        return message
    }
    func getListCart() -> Tb_Cart? {
        var cart: Tb_Cart?
        let request: NSFetchRequest<Tb_Cart> = Tb_Cart.fetchRequest()
        do {
            cart = try self.mainContext.fetch(request).first
        } catch let error {
            print("Error fetching. \(error)")
        }
        return cart
    }
    func reduceStock() -> Bool {
        var saveChanges: Bool = true
        //TODO: Arreglar esta funcion
        /*
        if let cartList = getListCart()?.toCartDetail as? Set<Tb_CartDetail> {
            for cartDetail in cartList {
                let reducedQuantity: Int64 = cartDetail.quantityAdded
                let filteredProducts = getListProducts().mapToListProductEntity(context: productsContainer.viewContext).filter { $0.idProduct == cartDetail.toProduct?.idProduct }
                if let productFound = filteredProducts.first {
                    if productFound.cantidadStock >= reducedQuantity {
                        productFound.cantidadStock -= reducedQuantity
                    } else {
                        saveChanges = false
                    }
                } else {
                    saveChanges = false
                }
            }
        }
        if saveChanges {
            saveData()
        } else {
            print("Eliminamos los cambios")
            self.productsContainer.viewContext.rollback()
        }
         */
        return saveChanges
    }
    func saveData () {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en ProductRepositoryImpl \(error)")
        }
    }
    func filterProducts(word: String) -> [Product] {
        var products: [Product] = []
        let fetchRequest: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        let predicate1 = NSPredicate(format: "nombreProducto CONTAINS[c] %@", word)
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
}
