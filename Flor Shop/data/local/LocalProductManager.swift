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
    let productsContainer: NSPersistentContainer
    var primaryOrder: PrimaryOrder = .nameAsc
    var filterAttribute: ProductsFilterAttributes = .allProducts
    init(containerBDFlor: NSPersistentContainer) {
        self.productsContainer = containerBDFlor
    }
    func getListProducts() -> [Product] {
        var productList: [Tb_Producto] = []
        let request: NSFetchRequest<Tb_Producto> = Tb_Producto.fetchRequest()
        let predicate = getFilterAtribute()
        request.predicate = predicate
        let sortDescriptor = getOrderFilter()
        request.sortDescriptors = [sortDescriptor]
        do {
            productList = try self.productsContainer.viewContext.fetch(request)
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
            if let productInContext = product.toProductEntity(context: productsContainer.viewContext) {
                productInContext.nombreProducto = product.name
                productInContext.cantidadStock = product.qty
                productInContext.costoUnitario = product.unitCost
                productInContext.fechaVencimiento = product.expirationDate
                productInContext.precioUnitario = product.unitPrice
                productInContext.tipoMedicion = product.type.description
                productInContext.url = product.url
            } else {
                _ = product.toNewProductEntity(context: productsContainer.viewContext)
            }
            saveData()
            message = "Success"
        } else {
            if !product.isProductNameValid() {
                message = "El nombre del producto esta mal \(product.name)"
            } else if !product.isQuantityValid() {
                message = "La cantidad y el tipo esta mal \(product.qty) \(product.type)"
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
    func getListCart() -> Tb_Carrito? {
        var cart: Tb_Carrito?
        let request: NSFetchRequest<Tb_Carrito> = Tb_Carrito.fetchRequest()
        do {
            cart = try self.productsContainer.viewContext.fetch(request).first
        } catch let error {
            print("Error fetching. \(error)")
        }
        return cart
    }
    func reduceStock() -> Bool {
        var saveChanges: Bool = true
        if let cartList = getListCart()?.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> {
            for cartDetail in cartList {
                let reducedQuantity: Double = cartDetail.cantidad
                let filteredProducts = getListProducts().mapToListProductEntity(context: productsContainer.viewContext).filter { $0.idProducto == cartDetail.detalleCarrito_to_producto?.idProducto }
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
        return saveChanges
    }
    func saveData () {
        do {
            try self.productsContainer.viewContext.save()
        } catch {
            print("Error al guardar en ProductRepositoryImpl \(error)")
        }
    }
    func filterProducts(word: String) -> [Product] {
        var products: [Product] = []
        let fetchRequest: NSFetchRequest<Tb_Producto> = Tb_Producto.fetchRequest()
        let predicate1 = NSPredicate(format: "nombreProducto CONTAINS[c] %@", word)
        let predicate2 = getFilterAtribute()
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicate1, predicate2])
        fetchRequest.predicate = compoundPredicate
        // Agregar el sort descriptor para ordenar por nombre ascendente
        let sortDescriptor = getOrderFilter()
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            // Ejecutar la consulta y obtener los resultados
            let productosBD = try self.productsContainer.viewContext.fetch(fetchRequest)
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
        var sortDescriptor = NSSortDescriptor(key: "nombreProducto", ascending: true)
        switch primaryOrder {
        case .nameAsc:
            sortDescriptor = NSSortDescriptor(key: "nombreProducto", ascending: true)
        case .nameDesc:
            sortDescriptor = NSSortDescriptor(key: "nombreProducto", ascending: false)
        case .priceAsc:
            sortDescriptor = NSSortDescriptor(key: "precioUnitario", ascending: true)
        case .priceDesc:
            sortDescriptor = NSSortDescriptor(key: "precioUnitario", ascending: false)
        case .quantityAsc:
            sortDescriptor = NSSortDescriptor(key: "cantidadStock", ascending: true)
        case .quantityDesc:
            sortDescriptor = NSSortDescriptor(key: "cantidadStock", ascending: false)
        }
        return sortDescriptor
    }
    func getFilterAtribute() -> NSPredicate {
        var filterAtt = NSPredicate(format: "cantidadStock != 0")
        switch filterAttribute {
        case .allProducts:
            filterAtt = NSPredicate(format: "cantidadStock != 0")
        case .outOfStock:
            filterAtt = NSPredicate(format: "cantidadStock == 0")
        case .productWithdrawn:
            filterAtt = NSPredicate(format: "cantidadStock == 0")
        }
        return filterAtt
    }
}
