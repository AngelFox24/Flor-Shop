//
//  Customer.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation

struct Customer: Identifiable {
    var id: UUID
    var name: String
    var lastName: String
    var image: ImageUrl
    var active: Bool
    var creditLimit: Double
}
