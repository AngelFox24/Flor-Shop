//
//  CartDetail.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 23/05/23.
//

import Foundation

struct CartDetail: Identifiable {
    let id: UUID
    let quantity: Double
    let subtotal: Double
    let product: Product
}
