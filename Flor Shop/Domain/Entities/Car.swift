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
    var totalRounded: Money {
        let cents = total.cents
        let remainder = cents % 10
        
        if remainder >= 5 {
            // Round up
            return Money(cents + (10 - remainder))
        } else {
            // Round down
            return Money(cents - remainder)
        }
    }
    var roundingDifference: Money {
        return Money(totalRounded.cents - total.cents)
    }
}

extension Car {
    func toCartDTO() -> CartServerDTO {
        return CartServerDTO(
            cartDetails: cartDetails.mapToListCartDetailsDTOs(),
            total: total.cents,
            totalRounded: totalRounded.cents
        )
    }
}

extension Array where Element == CartDetail {
    func mapToListCartDetailsDTOs() -> [CartDetailServerDTO] {
        return self.compactMap {$0.toCartDetailDTO()}
    }
}
