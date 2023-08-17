//
//  Employee.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation

struct Employee: Identifiable {
    var id: UUID
    var name: String
    var lastName: String
    var role: String
    var image: ImageUrl
    var active: Bool
}
