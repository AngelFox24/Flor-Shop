import Foundation
import FlorShop_DTOs

struct Customer: Identifiable {
    var id: UUID
    let customerId: UUID?
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
    var lastDatePurchase: Date
    var totalDebt: Money
    var isCreditLimitActive: Bool
    var isDateLimitActive: Bool
}

extension Customer {
    func toCustomerDTO(companyId: UUID) -> CustomerServerDTO {
        return CustomerServerDTO(
            id: customerId,
            name: name,
            lastName: lastName,
            totalDebt: totalDebt.cents,
            creditScore: creditScore,
            creditDays: creditDays,
            isCreditLimitActive: isCreditLimitActive,
            isCreditLimit: isCreditLimit,
            isDateLimitActive: isDateLimitActive,
            isDateLimit: isDateLimit,
            dateLimit: dateLimit,
            firstDatePurchaseWithCredit: firstDatePurchaseWithCredit,
            lastDatePurchase: lastDatePurchase,
            phoneNumber: phoneNumber,
            creditLimit: creditLimit.cents,
            companyID: companyId,
            imageUrl: image?.toImageUrlDTO()
        )
    }
}
