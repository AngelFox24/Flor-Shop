//
//  SaleDetail.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

struct SaleDetail: Identifiable {
    var id: UUID
    var image: ImageUrl?
    var barCode: String?
    var productName: String
    var unitType: UnitTypeEnum
    var unitCost: Money
    var unitPrice: Money
    var quantitySold: Int
    var paymentType: PaymentType
    var saleDate: Date
    var subtotal: Money
    
    static func == (lhs: SaleDetail, rhs: SaleDetail) -> Bool {
        return lhs.id == rhs.id
    }
}
