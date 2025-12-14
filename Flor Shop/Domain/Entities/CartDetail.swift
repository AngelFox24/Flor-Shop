import Foundation
import FlorShopDTOs

struct CartDetail: Identifiable {
    let id: UUID
    let quantity: Int
    let product: Product
    var subtotal: Money {
        let subTotal = quantity * product.unitPrice.cents
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
