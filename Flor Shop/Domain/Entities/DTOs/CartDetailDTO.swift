//
//  CartDetailDTO.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/07/2024.
//

import Foundation

struct CartDetailDTO: Codable {
//    let id: UUID
    let quantity: Int
    let subtotal: Int
    let productId: UUID
}
