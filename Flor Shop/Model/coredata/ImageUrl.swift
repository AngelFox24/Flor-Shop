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
        return ImageUrl(id: UUID(uuidString: "IM001") ?? UUID(), imageUrl: "https://img.freepik.com/vector-premium/ilustracion-vector-fachada-tienda-abarrotes-escaparate-edificio-tienda-vista-frontal-fachada-tienda-dibujos-animados-plana-eps-10_505557-737.jpg?w=2000")
    }
}
