//
//  SaleDTO.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation

struct SaleDTO: Codable {
    let id: UUID
    let paymentType: String
    let saleDate: Date
    let total: Int
    let subsidiaryId: UUID
    let customerId: UUID?
    let employeeId: UUID
    let saleDetail: [SaleDetailDTO]
    let createdAt: String
    let updatedAt: String
}

extension SaleDTO {
    func toSale() -> Sale {
        return Sale(
            id: id,
            paymentType: PaymentType.from(description: paymentType),
            saleDate: saleDate,
            saleDetail: saleDetail.mapToListSaleDetail(paymentType: paymentType, saleDate: saleDate),
            totalSale: Money(total),
            createdAt: createdAt.internetDateTime() ?? minimunDate(),
            updatedAt: updatedAt.internetDateTime() ?? minimunDate()
        )
    }
    func isEquals(to other: Tb_Sale) -> Bool {
        return (
            self.id == other.idSale &&
            self.paymentType == other.paymentType &&
            self.saleDate == other.saleDate &&
            self.total == other.total
        )
    }
}

extension Array where Element == SaleDTO {
    func mapToListSale() -> [Sale] {
        return self.compactMap({$0.toSale()})
    }
}
