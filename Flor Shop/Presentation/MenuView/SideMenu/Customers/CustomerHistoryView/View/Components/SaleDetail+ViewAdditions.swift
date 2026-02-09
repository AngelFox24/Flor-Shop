import SwiftUI

extension SaleDetail {
    var topStatusColor: Color {
        switch self.paymentType {
        case .cash: return .green
        case .loan: return .red
        }
    }
    var topStatus: String {
        let date: String = self.saleDate.formatted(.dateTime.day().month(.abbreviated).year())
        switch self.paymentType {
        case .cash:
            return "Pagado \(date)"
        case .loan:
            return "Sin Pagar \(date)"
        }
    }
    
    var quantityDisplay: String {
        switch self.unitType {
        case .unit:
            return String(quantitySold)
        case .kilo:
            let s = String(quantitySold)
            let numberOfDecimals = 3
            let newCeros = max((numberOfDecimals+1) - s.count, 0)
            var newString = String(repeating: "0", count: newCeros) + s
            if numberOfDecimals > 0 {
                let index = newString.index(newString.endIndex, offsetBy: -numberOfDecimals)
                newString.insert(".", at: index)
            }
            return newString
        }
    }
}
