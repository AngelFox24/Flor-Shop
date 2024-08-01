//
//  Subsidiary.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

struct Subsidiary: Identifiable {
    var id: UUID
    var name: String
    var image: ImageUrl?
    let createdAt: Date
    let updatedAt: Date
    static func getDummySubsidiary() -> Subsidiary {
        return Subsidiary(
            id: UUID(
                uuidString: "SU001"
            ) ?? UUID(),
            name: "Tienda de Flor",
            image: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

extension Subsidiary {
    func toSubsidiaryDTO(companyId: UUID) -> SubsidiaryDTO {
        return SubsidiaryDTO(
            id: id,
            name: name,
            companyID: companyId,
            imageUrl: image?.toImageUrlDTO(),
            createdAt: createdAt.description,
            updatedAt: updatedAt.description
        )
    }
}
