//
//  ModelMapper.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 21/05/23.
//

import Foundation
import CoreData



extension Product {
    
    func toNewProductEntity(context: NSManagedObjectContext) -> Tb_Producto {
        
        let newProduct = Tb_Producto(context: context)
        newProduct.idProducto = id
        newProduct.nombreProducto = name
        newProduct.cantidadStock = qty
        newProduct.costoUnitario = unitCost
        newProduct.precioUnitario = unitPrice
        newProduct.fechaVencimiento = expirationDate
        newProduct.tipoMedicion = type.description
        newProduct.url = url
        return newProduct
    }
    
    func toProductEntity(context: NSManagedObjectContext) -> Tb_Producto? {
        let fetchRequest: NSFetchRequest<Tb_Producto> = Tb_Producto.fetchRequest()
        var productList: [Tb_Producto] = []
        do{
            productList = try context.fetch(fetchRequest)
        } catch let error {
            print("Error fetching. \(error)")
        }
        if let product = productList.first(where: { $0.idProducto == id }) {
            print("Producto encontrado: \(product.nombreProducto ?? "")")
            return product
        } else {
            // No se encontró ningún producto con el ID especificado
            print("Producto no encontrado")
            return nil
        }
    }
}

extension Tb_Producto {
    func toProduct() -> Product {
        return Product(id: idProducto ?? UUID(),
                       name: nombreProducto ?? "",
                       qty: cantidadStock,
                       unitCost: costoUnitario,
                       unitPrice: precioUnitario,
                       expirationDate: fechaVencimiento ?? Date(),
                       type: TipoMedicion.from(description: tipoMedicion ?? "Kilos") ?? .Kg,
                       url: url ?? "", replaceImage: replaceImage)
    }
}

extension Tb_Venta {
    func toSale() -> Sale {
        return Sale(id: idVenta ?? UUID(),
                    saleDate: fechaVenta ?? Date(),
                    totalSale: totalVenta)
    }
}

extension Tb_Carrito {
    func mapToCar() -> Car {
        return Car(id: idCarrito ?? UUID(),
                   dateCar: fechaCarrito ?? Date(),
                   total: totalCarrito)
    }
}

extension Tb_DetalleCarrito {
    func mapToCarDetail() -> CartDetail {
        return CartDetail(
            id: idDetalleCarrito ?? UUID(),
            quantity: cantidad,
            subtotal: subtotal,
            product: detalleCarrito_to_producto?.toProduct() ?? Product())
    }
}

//MARK: Array Extencions
extension Array where Element == Tb_Producto {
    func mapToListProduct() -> [Product] {
        return self.map { prd in
            prd.toProduct()
        }
    }
}

extension Array where Element == Product {
    func mapToListProductEntity(context: NSManagedObjectContext) -> [Tb_Producto] {
        return self.compactMap { prd in
            prd.toProductEntity(context: context)
        }
    }
}

extension Array where Element == Tb_DetalleCarrito {
    func mapToListCartDetail() -> [CartDetail] {
        return self.map { prd in
            prd.mapToCarDetail()
        }
    }
}

extension Array where Element == Tb_Venta {
    func mapToListSale() -> [Sale] {
        return self.map { sale in
            sale.toSale()
        }
    }
}





