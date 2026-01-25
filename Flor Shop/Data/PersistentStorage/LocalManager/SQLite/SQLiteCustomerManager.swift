import Foundation
import PowerSync
import FlorShopDTOs

protocol LocalCustomerManager {
    func getCustomers(seachText: String, order: CustomerOrder, filter: CustomerFilterAttributes, page: Int, pageSize: Int) async throws -> [Customer]
    func getSalesDetailHistory(customer: Customer, page: Int, pageSize: Int) async throws -> [SaleDetail]
    func getCustomer(customerCic: String) async throws -> Customer?
}

final class SQLiteCustomerManager: LocalCustomerManager {
    let sessionConfig: SessionConfig
    let db: PowerSyncDatabaseProtocol
    init(
        sessionConfig: SessionConfig,
        db: PowerSyncDatabaseProtocol
    ) {
        self.sessionConfig = sessionConfig
        self.db = db
    }
    func getCustomers(seachText: String, order: CustomerOrder, filter: CustomerFilterAttributes, page: Int, pageSize: Int) async throws -> [Customer] {
        let offset = (page - 1) * pageSize

            var whereClauses: [String] = []
            var parameters: [Any] = []

            // 🔎 Búsqueda por texto
            if !seachText.isEmpty {
                whereClauses.append("(c.name LIKE ? OR c.last_name LIKE ? OR c.phone_number LIKE ?)")
                let like = "%\(seachText)%"
                parameters.append(contentsOf: [like, like, like])
            }

            // 🎯 Filtro por estado del cliente
            if let filterClause = filter.sqlWhereClause {
                whereClauses.append(filterClause)
            }

            // 🧩 WHERE final
            let whereSQL: String
            if whereClauses.isEmpty {
                whereSQL = ""
            } else {
                whereSQL = "WHERE " + whereClauses.joined(separator: " AND ")
            }

            // 🔢 ORDER
            let orderSQL = order.sqlOrderClause

            let sql = """
            SELECT
                c.customer_cic,
                c.name,
                c.last_name,
                c.total_debt,
                c.credit_score,
                c.credit_days,
                c.date_limit,
                c.first_date_purchase_with_credit,
                c.last_date_purchase,
                c.phone_number,
                c.credit_limit,
                c.image_url,
                c.is_credit_limit_active,
                c.is_date_limit_active
            FROM customers c
            \(whereSQL)
            \(orderSQL)
            LIMIT ? OFFSET ?
            """

        parameters.append(pageSize)
        parameters.append(offset)
        let finalParameters = parameters
        
        return try await db.readTransaction { tx in
            try tx.getAll(
                sql: sql,
                parameters: finalParameters,
                mapper: { cursor in
                    try Customer(
                        id: UUID(),
                        customerCic: cursor.getStringOptional(name: "customer_cic"),
                        name: try cursor.getString(name: "name"),
                        lastName: cursor.getStringOptional(name: "last_name"),
                        imageUrl: cursor.getStringOptional(name: "image_url"),
                        creditLimit: Money(try cursor.getInt(name: "credit_limit")),
                        creditDays: try cursor.getInt(name: "credit_days"),
                        creditScore: try cursor.getInt(name: "credit_score"),
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
                        totalDebt: Money(try cursor.getInt(name: "total_debt")),
                        isCreditLimitActive: try cursor.getBoolean(name: "is_credit_limit_active"),
                        isDateLimitActive: try cursor.getBoolean(name: "is_date_limit_active")
                    )
                }
            )
        }
    }
    
    func getSalesDetailHistory(customer: Customer, page: Int, pageSize: Int) async throws -> [SaleDetail] {
        guard let customerCic = customer.customerCic else {
                return []
            }

            let offset = (page - 1) * pageSize

            let sql = """
            SELECT
                sd.id,
                sd.product_name,
                sd.bar_code,
                sd.quantity_sold,
                sd.subtotal,
                sd.unit_type,
                sd.unit_cost,
                sd.unit_price,
                sd.image_url,
                s.payment_type,
                s.sale_date
            FROM sale_details sd
            JOIN sales s ON s.id = sd.sale_id
            WHERE s.customer_cic = ?
            ORDER BY s.sale_date DESC
            LIMIT ? OFFSET ?
            """
        
        return try await db.readTransaction { tx in
            try tx.getAll(
                sql: sql,
                parameters: [customerCic, pageSize, offset],
                mapper: { cursor in
                    try SaleDetail(
                        id: UUID(uuidString: try cursor.getString(name: "id")) ?? UUID(),
                        imageUrl: cursor.getStringOptional(name: "image_url"),
                        barCode: cursor.getStringOptional(name: "bar_code"),
                        productName: try cursor.getString(name: "product_name"),
                        unitType: UnitType(
                            rawValue: try cursor.getString(name: "unit_type")
                        ) ?? .unit,
                        unitCost: Money(try cursor.getInt(name: "unit_cost")),
                        unitPrice: Money(try cursor.getInt(name: "unit_price")),
                        quantitySold: try cursor.getInt(name: "quantity_sold"),
                        paymentType: PaymentType(
                            rawValue: try cursor.getString(name: "payment_type")
                        ) ?? .cash,
                        saleDate: ISO8601DateFormatter().date(
                            from: try cursor.getString(name: "sale_date")
                        ) ?? Date(),
                        subtotal: Money(try cursor.getInt(name: "subtotal"))
                    )
                }
            )
        }
    }
    
    func getCustomer(customerCic: String) async throws -> Customer? {
        let sql = """
                SELECT
                    c.customer_cic,
                    c.name,
                    c.last_name,
                    c.total_debt,
                    c.credit_score,
                    c.credit_days,
                    c.date_limit,
                    c.first_date_purchase_with_credit,
                    c.last_date_purchase,
                    c.phone_number,
                    c.credit_limit,
                    c.image_url,
                    c.is_credit_limit_active,
                    c.is_date_limit_active
                FROM customers c
                WHERE c.customer_cic = ?
                LIMIT 1
                """
        
        return try await db.readTransaction { tx in
            try tx.get(
                sql: sql,
                parameters: [customerCic],
                mapper: { cursor in
                    try Customer(
                        id: UUID(),
                        customerCic: cursor.getStringOptional(name: "customer_cic"),
                        name: try cursor.getString(name: "name"),
                        lastName: cursor.getStringOptional(name: "last_name"),
                        imageUrl: cursor.getStringOptional(name: "image_url"),
                        creditLimit: Money(try cursor.getInt(name: "credit_limit")),
                        creditDays: try cursor.getInt(name: "credit_days"),
                        creditScore: try cursor.getInt(name: "credit_score"),
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
                        totalDebt: Money(try cursor.getInt(name: "total_debt")),
                        isCreditLimitActive: try cursor.getBoolean(name: "is_credit_limit_active"),
                        isDateLimitActive: try cursor.getBoolean(name: "is_date_limit_active")
                    )
                }
            )
        }
    }
}

extension CustomerFilterAttributes {

    var sqlWhereClause: String? {
        switch self {
        case .allCustomers:
            return nil

        case .onTime:
            return "(c.is_date_limit_active = 0 AND c.is_credit_limit_active = 0)"

        case .dueByDate:
            return "(c.is_date_limit_active = 1)"

        case .excessAmount:
            return "(c.is_credit_limit_active = 1)"
        }
    }
}

extension CustomerOrder {
    var sqlOrderClause: String {
        switch self {
        case .nameAsc:
            return "ORDER BY c.name ASC"
        case .nextDate:
            return "ORDER BY c.date_limit ASC"
        case .quantityAsc:
            return "ORDER BY c.total_debt ASC"
        case .quantityDesc:
            return "ORDER BY c.total_debt DESC"
        }
    }
}
