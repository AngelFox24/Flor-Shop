//
//  SaleDetailDTO.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation

struct SaleDetailDTO: Codable {
    let id: UUID
    let productName: String
    let barCode: String
    let quantitySold: Int
    let subtotal: Int
    let unitType: String
    let unitCost: Int
    let unitPrice: Int
    let saleID: UUID
    let imageUrl: ImageURLDTO?
    let createdAt: String
    let updatedAt: String
}

extension SaleDetailDTO {
    func toSaleDetail(paymentType: String, saleDate: Date) -> SaleDetail {
        return SaleDetail(
            id: id,
            image: imageUrl?.toImageUrl(),
            barCode: barCode,
            productName: productName,
            unitType: unitType == UnitTypeEnum.unit.rawValue ? .unit : .kilo,
            unitCost: Money(unitCost),
            unitPrice: Money(unitPrice),
            quantitySold: quantitySold,
            paymentType: PaymentType.from(description: paymentType),
            saleDate: Date(),
            subtotal: Money(subtotal),
            createdAt: createdAt.internetDateTime() ?? minimunDate(),
            updatedAt: updatedAt.internetDateTime() ?? minimunDate()
        )
    }
}
