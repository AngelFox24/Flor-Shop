import Foundation
import FlorShop_DTOs

extension CustomerClientDTO {
    func toCustomer() -> Customer {
        return Customer(
            id: id,
            customerId: id,
            name: name,
            lastName: lastName,
            image: nil,
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
            isDateLimitActive: isDateLimitActive
        )
    }
    func isEquals(to other: Tb_Customer) -> Bool {
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
            self.dateLimit == other.dateLimit &&
            self.firstDatePurchaseWithCredit == other.firstDatePurchaseWithCredit &&
            self.lastDatePurchase == other.lastDatePurchase &&
            self.phoneNumber == other.phoneNumber &&
            self.creditLimit == other.creditLimit &&
            self.imageUrlId == other.toImageUrl?.idImageUrl &&
            self.syncToken == other.syncToken
        )
    }
}

extension Array where Element == CustomerClientDTO {
    func mapToListCustomers() -> [Customer] {
        return self.compactMap {$0.toCustomer()}
    }
}
