//
//  SaleDetail.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation

struct SaleDetail: Identifiable {
    var idSaleDetail: UUID
    var image: ImageUrl
    var productName: String
    var unitCost: Double
    var unitPrice: Double
    var quantitySold: Int
    var subtotal: Double
}
