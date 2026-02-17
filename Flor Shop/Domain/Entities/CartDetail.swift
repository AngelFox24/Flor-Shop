import Foundation
import FlorShopDTOs

struct CartDetail: Identifiable {
    let id: UUID
    let quantity: Int
    let product: Product
    var subtotal: Money {
        guard quantity > 0 else { return Money(1) }
        let subTotal: Int
        switch product.unitType {
        case .unit:
            subTotal = quantity * product.unitPrice.cents
        case .kilo:
            //El costo se redondea por defecto y es un valor aproximado al costo real, porque en teoria el costo puede ser una divicion con decimales infinitos.
            guard quantity > 0 else { return Money(0) }
            
            let precioEscalado = product.unitPrice.cents * quantity
            
            let redondeado = (precioEscalado + 500) / 1000
            print("Redondead: \(redondeado)")
            subTotal = max(1, redondeado)
        }
        return Money(subTotal)
    }
}

extension CartDetail {
    func toCartDetailDTO() -> CartDetailServerDTO? {
        guard let productCic = product.productCic else {
            return nil
        }
        return CartDetailServerDTO(
            quantity: quantity,
            subtotal: subtotal.cents,
            productCic: productCic
        )
    }
}

extension CartDetail {
    var quantityDisplay: String {
        switch self.product.unitType {
        case .unit:
            return String(quantity)
        case .kilo:
            let s = String(quantity)
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
