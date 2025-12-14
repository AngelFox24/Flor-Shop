import Foundation
import FlorShopDTOs

extension PaymentType {
    var icon: String {
        switch self {
        case .cash:
            return "dollarsign"
        case .loan:
            return "list.clipboard"
        }
    }
    static func == (lhs: PaymentType, rhs: PaymentType) -> Bool {
        return lhs.description == rhs.description
    }
}
