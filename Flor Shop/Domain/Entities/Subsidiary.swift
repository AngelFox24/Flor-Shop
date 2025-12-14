import Foundation
import FlorShopDTOs

struct Subsidiary: Identifiable {
    var id: UUID
    let subsidiaryCic: String?
    var name: String
    var imageUrl: String?
}

extension Subsidiary {
    func toSubsidiaryDTO() -> SubsidiaryServerDTO {
        return SubsidiaryServerDTO(
            subsidiaryCic: subsidiaryCic,
            name: name,
            imageUrl: imageUrl,
        )
    }
}
