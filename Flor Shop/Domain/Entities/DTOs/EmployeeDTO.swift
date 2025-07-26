import Foundation
import FlorShop_DTOs

extension EmployeeClientDTO {
    func toEmployee() -> Employee {
        return Employee(
            id: id,
            employeeId: id,
            name: name,
            user: user,
            email: email,
            lastName: lastName,
            role: role,
            image: nil,
            active: active,
            phoneNumber: phoneNumber
        )
    }
    func isEquals(to other: Tb_Employee) -> Bool {
        return (
            self.id == other.idEmployee &&
            self.user == other.user &&
            self.name == other.name &&
            self.lastName == other.lastName &&
            self.email == other.email &&
            self.phoneNumber == other.phoneNumber &&
            self.role == other.role &&
            self.active == other.active &&
            self.imageUrlId == other.toImageUrl?.idImageUrl &&
            self.syncToken == other.syncToken
        )
    }
}

extension Array where Element == EmployeeClientDTO {
    func mapToListEmployee() -> [Employee] {
        return self.compactMap({$0.toEmployee()})
    }
}
