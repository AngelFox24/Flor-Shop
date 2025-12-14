import Foundation
import FlorShopDTOs

extension EmployeeClientDTO {
//    func toEmployee() -> Employee {
//        return Employee(
//            id: UUID(),
//            employeeCic: employeeCic,
//            name: name,
//            email: email,
//            lastName: lastName,
//            role: rol,
//            imageUrl: imageUrl,
//            active: active,
//            phoneNumber: phoneNumber
//        )
//    }
    func isEquals(to other: Tb_Employee) -> Bool {
        return (
            self.employeeCic == other.employeeCic &&
            self.name == other.name &&
            self.lastName == other.lastName &&
            self.email == other.email &&
            self.phoneNumber == other.phoneNumber &&
            self.imageUrl == other.imageUrl &&
            self.syncToken == other.syncToken
        )
    }
}

//extension Array where Element == EmployeeClientDTO {
//    func mapToListEmployee() -> [Employee] {
//        return self.compactMap({$0.toEmployee()})
//    }
//}
