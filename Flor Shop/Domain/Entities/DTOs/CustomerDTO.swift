import Foundation
import FlorShopDTOs

extension CustomerClientDTO {
//    func toCustomer() -> Customer {
//        return Customer(
//            id: UUID(),
//            customerCic: customerCic,
//            name: name,
//            lastName: lastName,
//            imageUrl: imageUrl,
//            creditLimit: Money(creditLimit),
//            creditDays: creditDays,
//            creditScore: creditScore,
//            dateLimit: dateLimit,
//            firstDatePurchaseWithCredit: firstDatePurchaseWithCredit,
//            phoneNumber: phoneNumber,
//            lastDatePurchase: lastDatePurchase,
//            totalDebt: Money(totalDebt),
//            isCreditLimitActive: isCreditLimitActive,
//            isDateLimitActive: isDateLimitActive
//        )
//    }
    func isEquals(to other: Tb_Customer) -> Bool {
        return (
            self.customerCic == other.customerCic &&
            self.name == other.name &&
            self.lastName == other.lastName &&
            self.totalDebt == other.totalDebt &&
            self.creditScore == other.creditScore &&
            self.creditDays == other.creditDays &&
            self.isCreditLimitActive == other.isCreditLimitActive &&
            self.isDateLimitActive == other.isDateLimitActive &&
            self.dateLimit == other.dateLimit &&
            self.firstDatePurchaseWithCredit == other.firstDatePurchaseWithCredit &&
            self.lastDatePurchase == other.lastDatePurchase &&
            self.phoneNumber == other.phoneNumber &&
            self.creditLimit == other.creditLimit &&
            self.imageUrl == other.imageUrl &&
            self.syncToken == other.syncToken
        )
    }
}
//
//extension Array where Element == CustomerClientDTO {
//    func mapToListCustomers() -> [Customer] {
//        return self.compactMap {$0.toCustomer()}
//    }
//}
