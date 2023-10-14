//
//  ImageUrl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation

struct ImageUrl: Identifiable {
    var id: UUID
    var imageUrl: String
    static func getDummyImage() -> ImageUrl {
        return ImageUrl(id: UUID(uuidString: "IM001") ?? UUID(), imageUrl: "https://falabella.scene7.com/is/image/FalabellaPE/882833012_1?wid=800&hei=800&qlt=70")
    }
}
