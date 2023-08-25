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
    func setDefaultSubsidiary(employee: Employee)
}

class LocalProductManager: ProductManager {
    var primaryOrder: PrimaryOrder = .nameAsc
    var filterAttribute: ProductsFilterAttributes = .allProducts
    var mainSubsidiaryEntity: Tb_Subsidiary?
    let mainContext: NSManagedObjectContext
    init(mainContext: NSManagedObjectContext) {
        self.mainContext = mainContext
    }
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
        if let productInContext = product.toProductEntity(context: mainContext) {
            //Existe este producto, vamos a actualizarlo
            print("Se encontro producto, lo vamos a actualizar")
            productInContext.productName = product.name
            productInContext.quantityStock = Int64(product.qty)
            productInContext.unitCost = product.unitCost
            productInContext.expirationDate = product.expirationDate
            productInContext.unitPrice = product.unitPrice
            productInContext.toImageUrl?.imageUrl = product.image.imageUrl
            // TODO: asignar imagen correctamente
            //productInContext.toImageUrl = product.url
            saveData()
        } else {
            print("No se encontro producto, lo vamos a crear")
            //Creamos una nueva Imagen
            let newImage = Tb_ImageUrl(context: mainContext)
            newImage.idImageUrl = product.image.id
            newImage.imageUrl = product.image.imageUrl
            //Creamos un nuevo producto
            let newProduct = Tb_Product(context: mainContext)
            newProduct.idProduct = product.id
            newProduct.productName = product.name
            newProduct.quantityStock = Int64(product.qty)
            newProduct.unitCost = product.unitCost
            newProduct.unitPrice = product.unitPrice
            newProduct.expirationDate = product.expirationDate
            newProduct.toImageUrl = newImage
            saveData()
        }
        return "Success"
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
    func setDefaultSubsidiary(employee: Employee) {
        let employeeEntity = employee.toEmployeeEntity(context: mainContext)
        guard let employeeEntity = employee.toEmployeeEntity(context: mainContext), let subsidiaryEntity: Tb_Subsidiary = employeeEntity.toSubsidiary else {
            print("No se pudo asingar sucursar default")
            return
        }
        self.mainSubsidiaryEntity = subsidiaryEntity
    }
}
