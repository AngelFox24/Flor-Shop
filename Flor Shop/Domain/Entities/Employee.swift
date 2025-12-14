import Foundation
import FlorShopDTOs

struct Employee: Identifiable {
    var id: UUID
    let employeeCic: String?
    var name: String
    var email: String
    var lastName: String?
    var role: UserSubsidiaryRole
    var imageUrl: String?
    var active: Bool
    var phoneNumber: String?
}

extension Employee {
    func toEmployeeDTO() -> EmployeeServerDTO {
        return EmployeeServerDTO(
            employeeCic: employeeCic,
            name: name,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            role: role,
            active: active,
            imageUrl: imageUrl
        )
    }
}
