//
//  SubsidiaryDTO.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation

struct SubsidiaryDTO: Codable {
    let id: UUID
    let name: String
    let companyID: UUID
    let imageUrl: ImageURLDTO?
    let createdAt: String
    let updatedAt: String
}

extension SubsidiaryDTO {
    func toSubsidiary() -> Subsidiary {
        return Subsidiary(
            id: id,
            name: name,
            image: imageUrl?.toImageUrl(),
            createdAt: createdAt.internetDateTime() ?? minimunDate(),
            updatedAt: updatedAt.internetDateTime() ?? minimunDate()
        )
    }
}

extension Array where Element == SubsidiaryDTO {
    func mapToListSubsidiary() -> [Subsidiary] {
        return self.compactMap({$0.toSubsidiary()})
    }
}
