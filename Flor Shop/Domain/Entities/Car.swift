//
//  Car.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

struct Car: Identifiable {
    let id: UUID
    let cartDetails: [CartDetail]
    let total: Money
}

extension Car {
    func toCartDTO(subsidiaryId: UUID) -> CartDTO {
        return CartDTO(
            id: id,
            cartDetails: cartDetails.mapToListCartDetailsDTOs(subsidiaryId: subsidiaryId),
            total: total.cents
        )
    }
}

extension Array where Element == CartDetail {
    func mapToListCartDetailsDTOs(subsidiaryId: UUID) -> [CartDetailDTO] {
        return self.compactMap {$0.toCartDetailDTO(subsidiaryId: subsidiaryId)}
    }
}
