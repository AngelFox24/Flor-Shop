import Foundation
import FlorShopDTOs

extension SubsidiaryClientDTO {
//    func toSubsidiary() -> Subsidiary {
//        return Subsidiary(
//            id: UUID(),
//            subsidiaryCic: subsidiaryCic,
//            name: name,
//            imageUrl: imageUrl
//        )
//    }
    func isEquals(to other: Tb_Subsidiary) -> Bool {
        return (
            self.subsidiaryCic == other.subsidiaryCic &&
            self.name == other.name &&
            self.imageUrl == other.imageUrl &&
            self.syncToken == other.syncToken
        )
    }
}

//extension Array where Element == SubsidiaryClientDTO {
//    func mapToListSubsidiary() -> [Subsidiary] {
//        return self.compactMap({$0.toSubsidiary()})
//    }
//}
