import Foundation

enum SalesGrouperAttributes: CustomStringConvertible, Equatable {
    case historic
    case byProduct
    //case byEmployee
    case byCustomer
    var description: String {
        switch self {
        case .historic:
            return "Historico"
        case .byProduct:
            return "Por Producto"
        //case .byEmployee:
            //return "Por Empleado"
        case .byCustomer:
            return "Por Cliente"
        }
    }
    static var allValues: [SalesGrouperAttributes] {
        return [.historic, .byProduct, .byCustomer]
    }
    static func == (lhs: SalesGrouperAttributes, rhs: SalesGrouperAttributes) -> Bool {
        return lhs.description == rhs.description
    }
}

enum SalesDateInterval: CustomStringConvertible, Equatable {
    case diary
    case monthly
    case yearly
    var description: String {
        switch self {
        case .diary:
            return "Diario"
        case .monthly:
            return "Mensual"
        case .yearly:
            return "Anual"
        }
    }
    static var allValues: [SalesDateInterval] {
        return [.diary, .monthly, .yearly]
    }
    static func == (lhs: SalesDateInterval, rhs: SalesDateInterval) -> Bool {
        return lhs.description == rhs.description
    }
}

enum SalesOrder: CustomStringConvertible, Equatable {
    case dateAsc
    case dateDesc
    case quantityAsc
    case quantityDesc
    case incomeAsc
    case incomeDesc
    var description: String {
        switch self {
        case .dateAsc:
            return "Fecha Ascendente"
        case .dateDesc:
            return "Fecha Descendente"
        case .quantityAsc:
            return "Cantidad Ascendente"
        case .quantityDesc:
            return "Cantidad Descendente"
        case .incomeAsc:
            return "Ingreso Ascendente"
        case .incomeDesc:
            return "Ingreso Descendente"
        }
    }
    var longDescription: String {
        switch self {
        case .dateAsc:
            return "Fecha actual primero"
        case .dateDesc:
            return "Fecha pasado primero"
        case .quantityAsc:
            return "Cantidad de menor a mayor"
        case .quantityDesc:
            return "Cantidad de mayor a menor"
        case .incomeAsc:
            return "Ingreso de menor a mayor"
        case .incomeDesc:
            return "Ingreso de mayor a menor"
        }
    }
    static var allValues: [SalesOrder] {
        return [.dateAsc, .dateDesc, .quantityAsc, .quantityDesc, .incomeAsc, .incomeDesc]
    }
    static func from(description: String) -> SalesOrder? {
        for case let tipo in SalesOrder.allValues where tipo.description == description {
            return tipo
        }
        return nil
    }
    static func == (lhs: SalesOrder, rhs: SalesOrder) -> Bool {
            return lhs.description == rhs.description
        }
}
