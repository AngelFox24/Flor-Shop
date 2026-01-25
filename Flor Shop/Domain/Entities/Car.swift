import Foundation
import FlorShopDTOs

struct Car: Identifiable {
    let id: UUID
    let cartDetails: [CartDetail]
    let customerCic: String?
    var total: Money {
        return cartDetails.reduce(Money(0)) { subtotal, cartDetail in
            var sub = subtotal.cents
            sub += cartDetail.subtotal.cents
            return Money(sub)
        }
    }
}

extension Car {
    func toCartDTO() -> CartServerDTO {
        return CartServerDTO(
            cartDetails: cartDetails.mapToListCartDetailsDTOs(),
            total: total.cents
        )
    }
}

extension Array where Element == CartDetail {
    func mapToListCartDetailsDTOs() -> [CartDetailServerDTO] {
        return self.compactMap {$0.toCartDetailDTO()}
    }
}
