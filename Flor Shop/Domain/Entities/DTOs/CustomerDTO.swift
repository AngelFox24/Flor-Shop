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
    func isEquals(to other: Tb_Customer) -> Bool {
        var imageIsEquals = false
        if let image = self.imageUrl, let otherImage = other.toImageUrl {
            imageIsEquals = image.isEquals(to: otherImage)
        } else {
            imageIsEquals = true
        }
        return (
            self.id == other.idCustomer &&
            self.name == other.name &&
            self.lastName == other.lastName &&
            self.totalDebt == other.totalDebt &&
            self.creditScore == other.creditScore &&
            self.creditDays == other.creditDays &&
            self.isCreditLimitActive == other.isCreditLimitActive &&
            self.isCreditLimit == other.isCreditLimit &&
            self.isDateLimitActive == other.isDateLimitActive &&
            self.isDateLimit == other.isDateLimit &&
            self.dateLimit.internetDateTime() == other.dateLimit &&
            self.firstDatePurchaseWithCredit == other.firstDatePurchaseWithCredit &&
            self.lastDatePurchase.internetDateTime() == other.lastDatePurchase &&
            self.phoneNumber == other.phoneNumber &&
            self.creditLimit == other.creditLimit &&
            imageIsEquals
        )
    }
}

extension Array where Element == CustomerDTO {
    func mapToListCustomers() -> [Customer] {
        return self.compactMap {$0.toCustomer()}
    }
}
