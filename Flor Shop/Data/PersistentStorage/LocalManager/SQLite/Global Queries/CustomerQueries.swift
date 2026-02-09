import Foundation
import PowerSync
import FlorShopDTOs

enum CustomerQueries {
    static func getCustomer(customerCic: String, companyCic: String, tx: Transaction) throws -> Customer {
        let sql = """
        SELECT
            c.customer_cic,
            c.name,
            c.last_name,
            c.image_url,
            c.credit_limit,
            c.credit_days,
            c.credit_score,
            c.date_limit,
            c.first_date_purchase_with_credit,
            c.last_date_purchase,
            c.phone_number,
            c.total_debt,
            c.is_credit_limit_active,
            c.is_date_limit_active
        FROM customers c
        WHERE c.customer_cic = ? AND c.company_cic = ?
        LIMIT 1
        """
        
        return try tx.get(
            sql: sql,
            parameters: [customerCic, companyCic],
            mapper: { cursor in
                try Customer(
                    id: UUID(), // id local, customer_cic es el identificador de negocio
                    customerCic: cursor.getStringOptional(name: "customer_cic"),
                    name: cursor.getString(name: "name"),
                    lastName: cursor.getStringOptional(name: "last_name"),
                    imageUrl: cursor.getStringOptional(name: "image_url"),
                    creditLimit: Money(cursor.getInt(name: "credit_limit")),
                    creditDays: cursor.getInt(name: "credit_days"),
                    creditScore: cursor.getInt(name: "credit_score"),
                    dateLimit: cursor
                        .getStringOptional(name: "date_limit")
                        .flatMap { ISO8601DateFormatter().date(from: $0) },
                    firstDatePurchaseWithCredit: cursor
                        .getStringOptional(name: "first_date_purchase_with_credit")
                        .flatMap { ISO8601DateFormatter().date(from: $0) },
                    phoneNumber: cursor.getStringOptional(name: "phone_number"),
                    lastDatePurchase: cursor
                        .getStringOptional(name: "last_date_purchase")
                        .flatMap { ISO8601DateFormatter().date(from: $0) }
                    ?? Date(),
                    totalDebt: Money(cursor.getInt(name: "total_debt")),
                    isCreditLimitActive: cursor.getBoolean(name: "is_credit_limit_active"),
                    isDateLimitActive: cursor.getBoolean(name: "is_date_limit_active")
                )
            }
        )
    }
}
