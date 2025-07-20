import Foundation
import CoreData
import FlorShop_DTOs

struct ImageUrl: Identifiable, Codable {
    var id: UUID
    let imageUrlId: UUID?
    var imageUrl: String
    var imageHash: String
    var imageData: Data?
}

extension ImageUrl {
    func toImageUrlDTO() -> ImageURLServerDTO {
        return ImageURLServerDTO(
            id: imageUrlId,
            imageUrl: imageUrl,
            imageHash: imageHash,
            imageData: imageData
        )
    }
}
