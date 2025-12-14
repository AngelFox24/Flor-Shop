import Foundation
import FlorShopDTOs

struct SaleDetail: Identifiable {
    var id: UUID
    var imageUrl: String?
    var barCode: String?
    var productName: String
    var unitType: UnitType
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
