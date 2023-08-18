//
//  Subsidiary.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation

struct Subsidiary: Identifiable {
    var id: UUID
    var name: String
    var image: ImageUrl
    static func getDummySubsidiary() -> Subsidiary {
        return Subsidiary(id: UUID(uuidString: "SU001") ?? UUID(), name: "Tienda de Flor", image: ImageUrl.getDummyImage())
    }
}
