//
//  ModelMapper.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 21/05/23.
//

import Foundation
import CoreData

extension Product {
    func toNewProductEntity(context: NSManagedObjectContext) -> Tb_Product {
        //Esta mal, no cumple con mi estandar
        let newProduct = Tb_Product(context: context)
        newProduct.idProduct = id
        newProduct.productName = name
        newProduct.quantityStock = qty
        newProduct.unitCost = unitCost
        newProduct.unitPrice = unitPrice
        newProduct.expirationDate = expirationDate
        //TODO: Arreglar asignacion de imagen url
        //newProduct.toImageUrl = url
        return newProduct
    }
    func toProductEntity(context: NSManagedObjectContext) -> Tb_Product? {
        let fetchRequest: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        var productList: [Tb_Product] = []
        do {
            productList = try context.fetch(fetchRequest)
        } catch let error {
            print("Error fetching. \(error)")
        }
        if let product = productList.first(where: { $0.idProduct == id }) {
            print("Producto encontrado: \(product.productName ?? "")")
            return product
        } else {
            // No se encontró ningún producto con el ID especificado
            print("Producto no encontrado")
            return nil
        }
    }
}

extension Tb_Manager {
    func toManager() -> Manager {
        return Manager(id: idManager ?? UUID(),
                       name: name ?? "",
                       lastName: lastName ?? "")
    }
}

extension Tb_Product {
    func toProduct() -> Product {
        return Product(id: idProduct ?? UUID(),
                       name: productName ?? "",
                       qty: quantityStock,
                       unitCost: unitCost,
                       unitPrice: unitPrice,
                       expirationDate: expirationDate ?? Date(),
                       //TODO: Arreglar asignacion de imagen url, temporal url
                       url: "")
                       //url: url ?? "")
    }
}

extension Tb_Sale {
    func toSale() -> Sale {
        return Sale(id: idSale ?? UUID(),
                    saleDate: saleDate ?? Date(),
                    totalSale: total)
    }
}

extension Tb_Cart {
    func mapToCar() -> Car {
        return Car(id: idCart ?? UUID(),
                   total: total)
    }
}

extension Tb_CartDetail {
    func mapToCarDetail() -> CartDetail {
        return CartDetail(
            id: idCartDetail ?? UUID(),
            quantity: quantityAdded,
            subtotal: subtotal,
            product: toProduct?.toProduct() ?? Product())
    }
}

// MARK: Array Extencions
extension Array where Element == Tb_Product {
    func mapToListProduct() -> [Product] {
        return self.map { prd in
            prd.toProduct()
        }
    }
}

extension Array where Element == Product {
    func mapToListProductEntity(context: NSManagedObjectContext) -> [Tb_Product] {
        return self.compactMap { prd in
            prd.toProductEntity(context: context)
        }
    }
}

extension Array where Element == Tb_CartDetail {
    func mapToListCartDetail() -> [CartDetail] {
        return self.map { prd in
            prd.mapToCarDetail()
        }
    }
}

extension Array where Element == Tb_Sale {
    func mapToListSale() -> [Sale] {
        return self.map { sale in
            sale.toSale()
        }
    }
}
