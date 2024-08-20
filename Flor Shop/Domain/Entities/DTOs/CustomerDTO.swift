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
    let dateLimit: Date
    var firstDatePurchaseWithCredit: Date?
    let lastDatePurchase: Date
    let phoneNumber: String
    let creditLimit: Int
    let companyID: UUID
    let imageUrl: ImageURLDTO?
    let createdAt: String
    let updatedAt: String
}

extension CustomerDTO {
    func toCustomer() -> Customer {
        return Customer(
            id: id,
            name: name,
            lastName: lastName,
            image: imageUrl?.toImageUrl(),
            creditLimit: Money(creditLimit),
            isCreditLimit: isCreditLimit,
            creditDays: creditDays,
            isDateLimit: isDateLimit,
            creditScore: creditScore,
            dateLimit: dateLimit,
            firstDatePurchaseWithCredit: firstDatePurchaseWithCredit,
            phoneNumber: phoneNumber,
            lastDatePurchase: lastDatePurchase,
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