import Foundation
import CoreData
import FlorShop_DTOs

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
    func toCartDetailDTO(subsidiaryId: UUID) -> CartDetailServerDTO {
        return CartDetailServerDTO(
            quantity: quantity,
            subtotal: subtotal.cents,
            productId: product.id
        )
    }
}
