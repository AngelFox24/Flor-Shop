//
//  Employee.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

struct Employee: Identifiable {
    var id: UUID
    var name: String
    var user: String
    var email: String
    var lastName: String
    var role: String
    var image: ImageUrl?
    var active: Bool
    var phoneNumber: String
    let createdAt: Date
    let updatedAt: Date
}

extension Employee {
    func toEmployeeDTO(subsidiaryId: UUID) -> EmployeeDTO {
        return EmployeeDTO(
            id: id,
            user: user,
            name: name,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            role: role,
            active: active,
            subsidiaryID: subsidiaryId,
            imageUrlId: image?.id,
            createdAt: ISO8601DateFormatter().string(from: createdAt),
            updatedAt: ISO8601DateFormatter().string(from: updatedAt)
        )
    }
}
