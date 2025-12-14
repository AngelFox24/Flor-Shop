import Foundation
import FlorShopDTOs

struct Customer: Identifiable {
    var id: UUID
    let customerCic: String?
    var name: String
    var lastName: String?
    var imageUrl: String?
    var creditLimit: Money
    var creditDays: Int
    var creditScore: Int
    var dateLimit: Date?
    var firstDatePurchaseWithCredit: Date?
    var phoneNumber: String?
    var lastDatePurchase: Date
    var totalDebt: Money
    var isCreditLimitActive: Bool
    var isDateLimitActive: Bool
    
    var isDateLimit: Bool {
        if isDateLimitActive {
            return true
        } else {
            return false
        }
    }
    var isCreditLimit: Bool {
        if isCreditLimitActive {
            return true
        } else {
            return false
        }
    }
    var customerType: CustomerTipeByCredit {
        if creditScore >= 0 && creditScore < 33 {
            return .bad
        } else if creditScore >= 33 && creditScore < 66 {
            return .regular
        } else {
            return .good
        }
    }
}

extension Customer {
    func toCustomerDTO() -> CustomerServerDTO {
        return CustomerServerDTO(
            customerCic: customerCic,
            name: name,
            lastName: lastName,
            totalDebt: totalDebt.cents,
            creditScore: creditScore,
            creditDays: creditDays,
            isCreditLimitActive: isCreditLimitActive,
            isDateLimitActive: isDateLimitActive,
            dateLimit: dateLimit ?? Date(),
            firstDatePurchaseWithCredit: firstDatePurchaseWithCredit,
            lastDatePurchase: lastDatePurchase,
            phoneNumber: phoneNumber,
            creditLimit: creditLimit.cents,
            imageUrl: imageUrl
        )
    }
}
