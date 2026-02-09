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
        guard isDateLimitActive else { return false }
        guard let dateLimit, let firstDatePurchaseWithCredit else { return false }
        let today = Calendar.current.startOfDay(for: Date())
        let limitDay = Calendar.current.startOfDay(for: dateLimit)
        
        let daysUntilLimit = Calendar.current.dateComponents(
            [.day],
            from: today,
            to: limitDay
        ).day ?? 0
        return daysUntilLimit > creditDays
    }
    
    var isCreditLimit: Bool {
        guard isCreditLimitActive else { return false }
        return totalDebt.cents > creditLimit.cents
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
