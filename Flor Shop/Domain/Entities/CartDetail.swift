//
//  CartDetail.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 23/05/23.
//

import Foundation
import CoreData

struct CartDetail: Identifiable {
    let id: UUID
    let quantity: Int
    let product: Product
    var subtotal: Money {
        var subTotal = quantity * product.unitPrice.cents
        return Money(subTotal)
    }
}

extension CartDetail {
    func toCartDetailDTO(subsidiaryId: UUID) -> CartDetailDTO {
        return CartDetailDTO(
            quantity: quantity,
            subtotal: subtotal.cents,
            productId: product.id
        )
    }
}
