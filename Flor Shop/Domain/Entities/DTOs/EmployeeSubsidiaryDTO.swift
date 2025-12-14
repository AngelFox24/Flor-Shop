import Foundation
import FlorShopDTOs

extension EmployeeSubsidiaryClientDTO {
//    func toEmployee() -> Employee {
//        return Employee(
//            id: id,
//            employeeId: id,
//            name: name,
//            user: user,
//            email: email,
//            lastName: lastName,
//            role: role,
//            image: nil,
//            active: active,
//            phoneNumber: phoneNumber
//        )
//    }
    func isEquals(to other: Tb_EmployeeSubsidiary) -> Bool {
        guard let otherRole = other.role,
              let otherRoleEnum = UserSubsidiaryRole(rawValue: otherRole) else {
            return false
        }
        return (
            self.role == otherRoleEnum &&
            self.active == other.active
        )
    }
}

//extension Array where Element == EmployeeClientDTO {
//    func mapToListEmployee() -> [Employee] {
//        return self.compactMap({$0.toEmployee()})
//    }
//}
