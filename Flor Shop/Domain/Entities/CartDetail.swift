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
    let subtotal: Money
    let product: Product
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
