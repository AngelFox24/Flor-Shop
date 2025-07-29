import Foundation
import FlorShop_DTOs
import CoreData

struct Subsidiary: Identifiable {
    var id: UUID
    let subsidiaryId: UUID?
    var name: String
    var image: ImageUrl?
}

extension Subsidiary {
    func toSubsidiaryDTO(companyId: UUID) -> SubsidiaryServerDTO {
        return SubsidiaryServerDTO(
            id: subsidiaryId,
            name: name,
            companyID: companyId,
            imageUrl: image?.toImageUrlDTO()
        )
    }
}
