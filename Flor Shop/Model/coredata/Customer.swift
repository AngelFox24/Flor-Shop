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
    var dateLimit: Date
    var phoneNumber: String
    var totalDebt: Double
    
    static func getDummyCustomer() -> Customer {
        return Customer(id: UUID(), name: "Desconocido", lastName: "Desconocido", image: ImageUrl.getDummyImage(), active: true, creditLimit: 12.0, dateLimit: Date(), phoneNumber: "994947825", totalDebt: 23.53)
    }
}
