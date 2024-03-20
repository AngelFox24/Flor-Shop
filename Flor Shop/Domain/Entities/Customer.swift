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
    var isCreditLimit: Bool
    var isDateLimit: Bool
    var creditScore: Int
    var customerTipe: CustomerTipeByCredit {
        if creditScore >= 0 && creditScore < 33 {
            return .bad
        } else if creditScore >= 33 && creditScore < 66 {
            return .regular
        } else {
            return .good
        }
    }
    var dateLimit: Date
    var phoneNumber: String
    var totalDebt: Double
    var isCreditLimitActive: Bool
    var isDateLimitActive: Bool
    
    static func getDummyCustomer() -> Customer {
        return Customer(id: UUID(), name: "Desconocido", lastName: "Desconocido", image: ImageUrl.getDummyImage(), active: true, creditLimit: 12.0, isCreditLimit: false, isDateLimit: false, creditScore: 50, dateLimit: Date(), phoneNumber: "994947825", totalDebt: 23.53, isCreditLimitActive: false, isDateLimitActive: false)
    }
}
