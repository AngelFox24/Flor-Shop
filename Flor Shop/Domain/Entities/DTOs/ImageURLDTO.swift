import Foundation
import FlorShop_DTOs

extension ImageURLClientDTO {
    func toImageUrl() -> ImageUrl {
        return ImageUrl(
            id: id,
            imageUrlId: id,
            imageUrl: imageUrl,
            imageHash: imageHash
        )
    }
    
    func isEquals(to other: Tb_ImageUrl) -> Bool {
        return (
            self.id == other.idImageUrl &&
            self.imageUrl == other.imageUrl &&
            self.imageHash == other.imageHash
        )
    }
}
