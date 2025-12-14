import Foundation
import SwiftUI

enum CustomerFilterAttributes: CustomStringConvertible, Equatable {
    case allCustomers
    case onTime
    case dueByDate
    case excessAmount
    var description: String {
        switch self {
        case .allCustomers:
            return "Todos"
        case .onTime:
            return "A Tiempo"
        case .dueByDate:
            return "Vencidos por Fecha"
        case .excessAmount:
            return "Monto Excedido"
        }
    }
    static var allValues: [CustomerFilterAttributes] {
        return [.allCustomers, .onTime, .dueByDate, .excessAmount]
    }
    static func == (lhs: CustomerFilterAttributes, rhs: CustomerFilterAttributes) -> Bool {
        return lhs.description == rhs.description
    }
}
enum CustomerOrder: CustomStringConvertible, Equatable {
    case nameAsc
    case nextDate
    case quantityAsc
    case quantityDesc
    var description: String {
        switch self {
        case .nameAsc:
            return "Nombre Ascendente"
        case .nextDate:
            return "Fecha Proxima"
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
        case .nextDate:
            return "Fecha Proxima"
        case .quantityAsc:
            return "Cantidad de menor a mayor"
        case .quantityDesc:
            return "Cantidad de mayor a menor"
        }
    }
    static var allValues: [CustomerOrder] {
        return [.nameAsc, .nextDate, .quantityAsc, .quantityDesc]
    }
    static func from(description: String) -> CustomerOrder? {
        for case let tipo in CustomerOrder.allValues where tipo.description == description {
            return tipo
        }
        return nil
    }
    static func == (lhs: CustomerOrder, rhs: CustomerOrder) -> Bool {
        return lhs.description == rhs.description
    }
}

enum CustomerTipeByCredit: CustomStringConvertible, Equatable {
    case good
    case regular
    case bad
    var description: String {
        switch self {
        case .good:
            return "Buen Pagador"
        case .regular:
            return "Regular"
        case .bad:
            return "Morador"
        }
    }
    var color: Color {
        switch self {
        case .good:
            return .green
        case .regular:
            return .yellow
        case .bad:
            return .red
        }
    }
    static var allValues: [CustomerTipeByCredit] {
        return [.good, .regular, .bad]
    }
    static func from(description: String) -> CustomerTipeByCredit? {
        for case let tipo in CustomerTipeByCredit.allValues where tipo.description == description {
            return tipo
        }
        return nil
    }
    static func == (lhs: CustomerTipeByCredit, rhs: CustomerTipeByCredit) -> Bool {
        return lhs.description == rhs.description
    }
}
