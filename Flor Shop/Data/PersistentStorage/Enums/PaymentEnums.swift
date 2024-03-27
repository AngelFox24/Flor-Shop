//
//  PaymentEnums.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 14/10/23.
//

import Foundation

enum PaymentType: CustomStringConvertible, Equatable {
    case cash
    case loan
    var description: String {
        switch self {
        case .cash:
            return "Efectivo"
        case .loan:
            return "Fiado"
        }
    }
    var icon: String {
        switch self {
        case .cash:
            return "dollarsign"
        case .loan:
            return "list.clipboard"
        }
    }
    static var allValues: [PaymentType] {
        return [.cash, .loan]
    }
    static func == (lhs: PaymentType, rhs: PaymentType) -> Bool {
        return lhs.description == rhs.description
    }
    static func from(description: String) -> PaymentType {
        for case let tipo in PaymentType.allValues where tipo.description == description {
            return tipo
        }
        return PaymentType.loan
    }
}
