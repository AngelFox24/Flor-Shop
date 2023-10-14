//
//  PaymentEnums.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 14/10/23.
//

import Foundation

enum PaymentEnums: CustomStringConvertible, Equatable {
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
    static var allValues: [PaymentEnums] {
        return [.cash, .loan]
    }
    static func == (lhs: PaymentEnums, rhs: PaymentEnums) -> Bool {
        return lhs.description == rhs.description
    }
}
