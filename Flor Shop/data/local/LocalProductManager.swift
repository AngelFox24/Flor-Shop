//
//  LocalProductManager.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 21/05/23.
//

import Foundation
import CoreData

enum PrimaryOrder: CustomStringConvertible {
    case nameAsc
    case nameDesc
    case priceAsc
    case priceDesc
    case quantityAsc
    case quantityDesc
    var description: String {
        switch self {
        case .nameAsc:
            return "Nombre Ascendente"
        case .nameDesc:
            return "Nombre Descendente"
        case .priceAsc:
            return "Precio Ascendente"
        case .priceDesc:
            return "Precio Descendente"
        case .quantityAsc:
            return "Cantidad Ascendente"
        case .quantityDesc:
            return "Cantidad Descendente"
        }
    }
    var longDescription: String {
        switch self {
        case .nameAsc:
            return "Nombre A-Z"
        case .nameDesc:
            return "Nombre Z-A"
        case .priceAsc:
            return "Precio de menor a mayor"
        case .priceDesc:
            return "Precio de mayor a menor"
        case .quantityAsc:
            return "Cantidad de menor a mayor"
        case .quantityDesc:
            return "Cantidad de mayor a menor"
        }
    }
    static var allValues: [PrimaryOrder] {
        return [.nameAsc, .nameDesc, .priceAsc, .priceDesc, .quantityAsc, .quantityDesc]
    }
    static func from(description: String) -> PrimaryOrder? {
        for case let tipo in PrimaryOrder.allValues where tipo.description == description {
                return tipo
        }
        return nil
    }
}

protocol ProductManager {
    func saveProduct(product: Product) -> String
    func getListProducts() -> [Product]
    func reduceStock() -> Bool
    func filterProducts(word: String) -> [Product]
    func setPrimaryFilter(filter: PrimaryOrder)
}

class LocalProductManager: ProductManager {
    let productsContainer: NSPersistentContainer
    var primaryOrder: PrimaryOrder = .nameAsc
    init(containerBDFlor: NSPersistentContainer) {
        self.productsContainer = containerBDFlor
    }
    func getListProducts() -> [Product] {
        var productList: [Tb_Producto] = []
        let request: NSFetchRequest<Tb_Producto> = Tb_Producto.fetchRequest()
        let sortDescriptor = setOrderFilter()
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
        let predicate = NSPredicate(format: "nombreProducto CONTAINS[c] %@", word)
        fetchRequest.predicate = predicate
        // Agregar el sort descriptor para ordenar por nombre ascendente
        let sortDescriptor = setOrderFilter()
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
    func setPrimaryFilter(filter: PrimaryOrder) {
        self.primaryOrder = filter
    }
    func setOrderFilter() -> NSSortDescriptor {
        var sortDescriptor = NSSortDescriptor(key: "nombreProducto", ascending: true)
        if primaryOrder == .nameDesc {
            sortDescriptor = NSSortDescriptor(key: "nombreProducto", ascending: false)
        } else if primaryOrder == .priceAsc {
            sortDescriptor = NSSortDescriptor(key: "precioUnitario", ascending: true)
        } else if primaryOrder == .priceDesc {
            sortDescriptor = NSSortDescriptor(key: "precioUnitario", ascending: false)
        } else if primaryOrder == .quantityAsc {
            sortDescriptor = NSSortDescriptor(key: "cantidadStock", ascending: true)
        } else if primaryOrder == .quantityDesc {
            sortDescriptor = NSSortDescriptor(key: "cantidadStock", ascending: false)
        }
        return sortDescriptor
    }
}
