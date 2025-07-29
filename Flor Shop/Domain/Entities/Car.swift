import Foundation
import FlorShop_DTOs

struct Car: Identifiable {
    let id: UUID
    let cartDetails: [CartDetail]
    var total: Money {
        return cartDetails.reduce(Money(0)) { subtotal, cartDetail in
            var sub = subtotal.cents
            sub += cartDetail.subtotal.cents
            return Money(sub)
        }
    }
}

extension Car {
    func toCartDTO(subsidiaryId: UUID) -> CartServerDTO {
        return CartServerDTO(
            cartDetails: cartDetails.mapToListCartDetailsDTOs(subsidiaryId: subsidiaryId),
            total: total.cents
        )
    }
}

extension Array where Element == CartDetail {
    func mapToListCartDetailsDTOs(subsidiaryId: UUID) -> [CartDetailServerDTO] {
        return self.compactMap {$0.toCartDetailDTO(subsidiaryId: subsidiaryId)}
    }
}
