//
//  ProductsEnums.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 11/08/23.
//

import Foundation

enum UnitTypeEnum: String, Codable {
    case unit = "Unit"
    case kilo = "Kilo"
    
    var description: String {
        switch self {
        case .unit:
            return "Unidad"
        case .kilo:
            return "Kilogramo"
        }
    }
    
    static var allValues: [UnitTypeEnum] {
        return [.unit, .kilo]
    }
}

enum ProductsFilterAttributes: CustomStringConvertible, Equatable {
    case allProducts
    case outOfStock
    case productWithdrawn
    var description: String {
        switch self {
        case .allProducts:
            return "Todos"
        case .outOfStock:
            return "Solo sin Stock"
        case .productWithdrawn:
            return "Productos Retirados"
        }
    }
    static var allValues: [ProductsFilterAttributes] {
        return [.allProducts, .outOfStock, .productWithdrawn]
    }
    static func == (lhs: ProductsFilterAttributes, rhs: ProductsFilterAttributes) -> Bool {
        return lhs.description == rhs.description
    }
}
enum PrimaryOrder: CustomStringConvertible, Equatable {
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
    static func == (lhs: PrimaryOrder, rhs: PrimaryOrder) -> Bool {
        return lhs.description == rhs.description
    }
}
