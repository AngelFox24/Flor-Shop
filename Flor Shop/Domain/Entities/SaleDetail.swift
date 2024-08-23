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
    let createdAt: Date
    let updatedAt: Date
    
    static func == (lhs: SaleDetail, rhs: SaleDetail) -> Bool {
        return lhs.id == rhs.id
    }
}

extension SaleDetail {
    func toSaleDetailDTO(saleID: UUID) -> SaleDetailDTO {
        return SaleDetailDTO(
            id: id,
            productName: productName,
            barCode: barCode ?? "",
            quantitySold: quantitySold,
            subtotal: subtotal.cents,
            unitType: unitType.description,
            unitCost: unitCost.cents,
            unitPrice: unitPrice.cents,
            saleID: saleID,
            imageUrlId: image?.id,
            createdAt: ISO8601DateFormatter().string(from: createdAt),
            updatedAt: ISO8601DateFormatter().string(from: updatedAt)
        )
    }
}

extension Array where Element == SaleDetail {
    func mapToListSaleDetailDTO(saleID: UUID) -> [SaleDetailDTO] {
        return self.compactMap {$0.toSaleDetailDTO(saleID: saleID)}
    }
}
