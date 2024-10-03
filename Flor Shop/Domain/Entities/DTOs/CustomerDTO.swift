//
//  CustomerDTO.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation

struct CustomerDTO: Codable {
    let id: UUID
    let name: String
    let lastName: String
    let totalDebt: Int
    let creditScore: Int
    let creditDays: Int
    let isCreditLimitActive: Bool
    let isCreditLimit: Bool
    let isDateLimitActive: Bool
    let isDateLimit: Bool
    let dateLimit: String
    var firstDatePurchaseWithCredit: Date?
    let lastDatePurchase: String
    let phoneNumber: String
    let creditLimit: Int
    let companyID: UUID
    let imageUrlId: UUID?
    let createdAt: String
    let updatedAt: String
}

extension CustomerDTO {
    func toCustomer() -> Customer {
        return Customer(
            id: id,
            name: name,
            lastName: lastName,
            image: nil,
            creditLimit: Money(creditLimit),
            isCreditLimit: isCreditLimit,
            creditDays: creditDays,
            isDateLimit: isDateLimit,
            creditScore: creditScore,
            dateLimit: dateLimit.internetDateTime() ?? minimunDate(),
            firstDatePurchaseWithCredit: firstDatePurchaseWithCredit,
            phoneNumber: phoneNumber,
            lastDatePurchase: lastDatePurchase.internetDateTime() ?? minimunDate(),
            totalDebt: Money(totalDebt),
            isCreditLimitActive: isCreditLimitActive,
            isDateLimitActive: isDateLimitActive,
            createdAt: createdAt.internetDateTime() ?? minimunDate(),
            updatedAt: updatedAt.internetDateTime() ?? minimunDate()
        )
    }
}

extension Array where Element == CustomerDTO {
    func mapToListCustomers() -> [Customer] {
        return self.compactMap {$0.toCustomer()}
    }
}
