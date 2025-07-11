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
            image: nil,
            createdAt: createdAt.internetDateTime() ?? minimunDate(),
            updatedAt: updatedAt.internetDateTime() ?? minimunDate()
        )
    }
    func isEquals(to other: Tb_Subsidiary) -> Bool {
        var imageIsEquals = false
        if let image = self.imageUrl, let otherImage = other.toImageUrl {
            imageIsEquals = image.isEquals(to: otherImage)
        } else {
            imageIsEquals = true
        }
        return (
            self.id == other.idSubsidiary &&
            self.name == other.name &&
            imageIsEquals
        )
    }
}

extension Array where Element == SubsidiaryDTO {
    func mapToListSubsidiary() -> [Subsidiary] {
        return self.compactMap({$0.toSubsidiary()})
    }
}
