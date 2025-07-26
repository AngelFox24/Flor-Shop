import Foundation
import FlorShop_DTOs

extension SubsidiaryClientDTO {
    func toSubsidiary() -> Subsidiary {
        return Subsidiary(
            id: id,
            subsidiaryId: id,
            name: name,
            image: nil
        )
    }
    func isEquals(to other: Tb_Subsidiary) -> Bool {
        return (
            self.id == other.idSubsidiary &&
            self.name == other.name &&
            self.imageUrlId == other.toImageUrl?.idImageUrl &&
            self.syncToken == other.syncToken
        )
    }
}

extension Array where Element == SubsidiaryClientDTO {
    func mapToListSubsidiary() -> [Subsidiary] {
        return self.compactMap({$0.toSubsidiary()})
    }
}
