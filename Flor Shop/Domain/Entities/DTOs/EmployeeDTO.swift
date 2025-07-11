//
//  EmployeeDTO.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation

struct EmployeeDTO: Codable {
    let id: UUID
    let user: String
    let name: String
    let lastName: String
    let email: String
    let phoneNumber: String
    let role: String
    let active: Bool
    let subsidiaryID: UUID
    let imageUrl: ImageURLDTO?
    let createdAt: String
    let updatedAt: String
}

extension EmployeeDTO {
    func toEmployee() -> Employee {
        return Employee(
            id: id,
            name: name,
            user: user,
            email: email,
            lastName: lastName,
            role: role,
            image: nil,
            active: active,
            phoneNumber: phoneNumber,
            createdAt: createdAt.internetDateTime() ?? minimunDate(),
            updatedAt: updatedAt.internetDateTime() ?? minimunDate()
        )
    }
    func isEquals(to other: Tb_Employee) -> Bool {
        var imageIsEquals = false
        if let image = self.imageUrl, let otherImage = other.toImageUrl {
            imageIsEquals = image.isEquals(to: otherImage)
        } else {
            imageIsEquals = true
        }
        return (
            self.id == other.idEmployee &&
            self.user == other.user &&
            self.name == other.name &&
            self.lastName == other.lastName &&
            self.email == other.email &&
            self.phoneNumber == other.phoneNumber &&
            self.role == other.role &&
            self.active == other.active &&
            imageIsEquals
        )
    }
}

extension Array where Element == EmployeeDTO {
    func mapToListEmployee() -> [Employee] {
        return self.compactMap({$0.toEmployee()})
    }
}
