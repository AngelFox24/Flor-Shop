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
    let imageUrlId: UUID?
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
}

extension Array where Element == EmployeeDTO {
    func mapToListEmployee() -> [Employee] {
        return self.compactMap({$0.toEmployee()})
    }
}
