import Foundation
import FlorShop_DTOs

struct Employee: Identifiable {
    var id: UUID
    let employeeId: UUID?
    var name: String
    var user: String
    var email: String
    var lastName: String
    var role: String
    var image: ImageUrl?
    var active: Bool
    var phoneNumber: String
}

extension Employee {
    func toEmployeeDTO(subsidiaryId: UUID) -> EmployeeServerDTO {
        return EmployeeServerDTO(
            id: employeeId,
            user: user,
            name: name,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            role: role,
            active: active,
            subsidiaryID: subsidiaryId,
            imageUrl: image?.toImageUrlDTO()
        )
    }
}
