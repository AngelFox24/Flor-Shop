//
//  CartDTO.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/07/2024.
//

import Foundation

struct CartDTO: Codable {
    let id: UUID
    let cartDetails: [CartDetailDTO]
    let total: Int
}
