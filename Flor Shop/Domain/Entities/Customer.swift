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
    var image: ImageUrl?
    var creditLimit: Money
    var isCreditLimit: Bool
    var creditDays: Int
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
    var firstDatePurchaseWithCredit: Date?
    var phoneNumber: String
    var totalDebt: Money
    var isCreditLimitActive: Bool
    var isDateLimitActive: Bool
    
    static func getDummyCustomer() -> Customer {
        return Customer(id: UUID(), name: "Desconocido", lastName: "Desconocido", image: nil, creditLimit: Money(1200), isCreditLimit: false, creditDays: 30, isDateLimit: false, creditScore: 50, dateLimit: Date(), phoneNumber: "994947825", totalDebt: Money(2300), isCreditLimitActive: false, isDateLimitActive: false)
    }
}
