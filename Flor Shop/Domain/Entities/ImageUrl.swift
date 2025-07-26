import Foundation
import CoreData
import FlorShop_DTOs

struct ImageUrl: Identifiable, Codable, Equatable {
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
    func isEquals(to other: ImageUrl?) -> Bool {
        guard let other = other else {
            return false
        }
        return (
            self.imageUrlId == other.imageUrlId &&
            self.imageUrl == other.imageUrl &&
            self.imageHash == other.imageHash
        )
    }
}
