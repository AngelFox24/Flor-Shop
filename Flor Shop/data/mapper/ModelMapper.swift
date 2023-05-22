//
//  ModelMapper.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 21/05/23.
//

import Foundation
import CoreData



extension Product {
    
    func toProductEntity(context: NSManagedObjectContext) -> Tb_Producto {
        
        let newProduct = Tb_Producto(context: context)
        newProduct.idProducto = UUID()
        newProduct.nombreProducto=name
        newProduct.cantidadStock=qty
        newProduct.costoUnitario=unitCost
        newProduct.precioUnitario=unitPrice
        newProduct.fechaVencimiento=expirationDate
        newProduct.tipoMedicion=type
        newProduct.url=url
    
        return newProduct
    }
}

extension Tb_Producto {
    func toProduct() -> Product {
        return Product(name: nombreProducto ?? "",
                       qty: cantidadStock,
                       unitCost: costoUnitario,
                       unitPrice: precioUnitario,
                       expirationDate: fechaVencimiento ?? Date(),
                       type: tipoMedicion ?? "",
                       url: url ?? "")
    }
}

extension Tb_Venta {
    func toSale() -> Sale {
        return Sale(saleDate: fechaVenta ?? Date(),
                    totalSale: totalVenta)
    }
}

extension Tb_Carrito {
    func mapToCar() -> Car {
        return Car(dateCar: fechaCarrito ?? Date(), total: totalCarrito)
    }
}

extension Array where Element == Tb_Producto {
    
    func mapToListProduct() -> [Product] {
        return self.map { prd in
            prd.toProduct()
        }
    }
}

extension Array where Element == Product {
    
    func mapToListProductEntity(context: NSManagedObjectContext) -> [Tb_Producto] {
        return self.map { prd in
            prd.toProductEntity(context: context)
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





