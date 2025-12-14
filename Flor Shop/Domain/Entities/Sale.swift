import Foundation
import FlorShopDTOs

struct Sale: Identifiable {
    let id: UUID
    let paymentType: PaymentType
    let saleDate: Date
    let saleDetail: [SaleDetail]
    let totalSale: Money
}

struct SaleRequest: Codable {
    let subsidiaryId: UUID
    let updatedSince: String
}
