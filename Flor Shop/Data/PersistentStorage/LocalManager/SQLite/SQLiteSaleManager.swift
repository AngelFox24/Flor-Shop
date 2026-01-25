import Foundation
import PowerSync
import FlorShopDTOs

protocol LocalSaleManager {
    func getSalesDetailsHistoric(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) async throws -> [SaleDetail]
    func getSalesDetailsGroupedByProduct(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes)  async throws -> [SaleDetail]
    func getSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) async throws -> [SaleDetail]
    func getSalesAmount(date: Date, interval: SalesDateInterval) async throws -> Money
    func getCostAmount(date: Date, interval: SalesDateInterval) async throws -> Money
    func getRevenueAmount(date: Date, interval: SalesDateInterval) async throws -> Money
}

final class SQLiteSaleManager: LocalSaleManager {
    let sessionConfig: SessionConfig
    let db: PowerSyncDatabaseProtocol
    init(
        sessionConfig: SessionConfig,
        db: PowerSyncDatabaseProtocol
    ) {
        self.sessionConfig = sessionConfig
        self.db = db
    }
    func getSalesDetailsHistoric(
        page: Int,
        pageSize: Int,
        sale: Sale?,
        date: Date,
        interval: SalesDateInterval,
        order: SalesOrder,
        grouper: SalesGrouperAttributes
    ) async throws -> [SaleDetail] {
        let dateString = date.sqliteString()
            let offset = (page - 1) * pageSize

            var sql = """
                SELECT
                    sd.product_name,
                    sd.image_url,
                    sd.bar_code,
                    sd.unit_type,
                    sd.quantity_sold,
                    sd.subtotal,
                    s.payment_type,
                    s.sale_date
                FROM sale_details sd
                JOIN sales s ON s.id = sd.sale_id
                WHERE \(interval.whereClause)
                  AND s.subsidiary_cic = ?
            """

            var parameters: [Any?] = [dateString, sessionConfig.subsidiaryCic]

            if let sale = sale {
                sql += " AND s.id = ?"
                parameters.append(sale.id.uuidString)
            }

            sql += """
                ORDER BY \(order.historicOrderByClause)
                LIMIT ? OFFSET ?
            """

            parameters.append(pageSize)
            parameters.append(offset)

            let finalSql = sql
            let finalParameters = parameters

            return try await db.readTransaction { tx in
                try tx.getAll(
                    sql: finalSql,
                    parameters: finalParameters,
                    mapper: { cursor in
                        try SaleDetail(
                            id: UUID(),
                            imageUrl: cursor.getStringOptional(name: "image_url"),
                            barCode: cursor.getStringOptional(name: "bar_code"),
                            productName: cursor.getString(name: "product_name"),
                            unitType: UnitType(rawValue: cursor.getString(name: "unit_type")) ?? .unit,
                            unitCost: Money(0),
                            unitPrice: Money(0),
                            quantitySold: cursor.getInt(name: "quantity_sold"),
                            paymentType: PaymentType(rawValue: cursor.getString(name: "payment_type")) ?? .cash,
                            saleDate: ISO8601DateFormatter().date(from: cursor.getString(name: "sale_date")) ?? Date(),
                            subtotal: Money(cursor.getInt(name: "subtotal"))
                        )
                    }
                )
            }
    }
    
    func getSalesDetailsGroupedByProduct(
        page: Int,
        pageSize: Int,
        sale: Sale?,
        date: Date,
        interval: SalesDateInterval,
        order: SalesOrder,
        grouper: SalesGrouperAttributes
    ) async throws -> [SaleDetail] {
        let dateString = date.sqliteString()
        let offset = (page - 1) * pageSize
        
        var sql = """
                SELECT
                    sd.product_name,
                    sd.image_url,
                    SUM(sd.quantity_sold) AS total_quantity,
                    SUM(sd.subtotal) AS total_income
                FROM sale_details sd
                JOIN sales s ON s.id = sd.sale_id
                WHERE \(interval.whereClause) AND s.subsidiary_cic = ?
            """
        
        var parameters: [Any?] = [dateString, sessionConfig.subsidiaryCic]
        
        if let sale = sale {
            sql += " AND s.id = ?"
            parameters.append(sale.id.uuidString)
        }
        
        sql += """
                GROUP BY sd.product_name, sd.image_url
                ORDER BY \(order.orderByClause)
                LIMIT ? OFFSET ?
            """
        
        parameters.append(pageSize)
        parameters.append(offset)
        
        let finalSql = sql
        let finalParameters = parameters
        
        return try await db.readTransaction { tx in
            try tx.getAll(
                sql: finalSql,
                parameters: finalParameters,
                mapper: { cursor in
                    try SaleDetail(
                        id: UUID(),
                        imageUrl: cursor.getStringOptional(name: "image_url"),
                        productName: cursor.getString(name: "product_name"),
                        unitType: .unit,
                        unitCost: Money(0),
                        unitPrice: Money(0),
                        quantitySold: cursor.getInt(name: "total_quantity"),
                        paymentType: .cash,
                        saleDate: date,
                        subtotal: Money(cursor.getInt(name: "total_income"))
                    )
                }
            )
        }
    }
    
    func getSalesDetailsGroupedByCustomer(
        page: Int,
        pageSize: Int,
        sale: Sale?,
        date: Date,
        interval: SalesDateInterval,
        order: SalesOrder,
        grouper: SalesGrouperAttributes
    ) async throws -> [SaleDetail] {
        let dateString = date.sqliteString()
        let offset = (page - 1) * pageSize
        
        var sql = """
                SELECT
                  COALESCE(s.customer_id, 'UNASSIGNED') AS customer_id,
                  SUM(sd.quantity_sold) AS total_quantity,
                  SUM(sd.subtotal) AS total_income
                FROM sale_details sd
                JOIN sales s ON s.id = sd.sale_id
                WHERE \(interval.whereClause) AND s.subsidiary_cic = ?
            """
        
        var parameters: [Any?] = [dateString, sessionConfig.subsidiaryCic]
        
        if let sale = sale {
            sql += " AND s.id = ?"
            parameters.append(sale.id.uuidString)
        }
        
        sql += """
                GROUP BY s.customer_id
                ORDER BY \(order.orderByClause)
                LIMIT ? OFFSET ?
            """
        
        parameters.append(pageSize)
        parameters.append(offset)
        
        let finalSql = sql
        let finalParameters = parameters
        
        return try await db.readTransaction { tx in
            try tx.getAll(
                sql: finalSql,
                parameters: finalParameters,
                mapper: { cursor in
                    let customerId = try cursor.getString(name: "customer_id")
                    return try SaleDetail(
                        id: UUID(),
                        imageUrl: nil,
                        productName: customerId == "UNASSIGNED"
                        ? "Venta sin cliente"
                        : customerId,
                        unitType: .unit,
                        unitCost: Money(0),
                        unitPrice: Money(0),
                        quantitySold: cursor.getInt(name: "total_quantity"),
                        paymentType: .cash,
                        saleDate: date,
                        subtotal: Money(cursor.getInt(name: "total_income"))
                    )
                }
            )
        }
    }
    
    func getSalesAmount(date: Date, interval: SalesDateInterval) async throws -> Money {
        let dateString = date.sqliteString()
        
        let sql: String = """
            SELECT COALESCE(SUM(s.total), 0) AS sales_amount
            FROM sales s
            WHERE \(interval.whereClause)
            """
        
        return try await db.readTransaction { tx in
            let amount = try tx.get(
                sql: sql,
                parameters: [dateString],
                mapper: { cursor in
                    try cursor.getInt(name: "sales_amount")
                }
            )
            return Money(amount)
        }
    }
    
    func getCostAmount(date: Date, interval: SalesDateInterval) async throws -> Money {
        let dateString = date.sqliteString()
        
        let sql = """
            SELECT COALESCE(SUM(sd.unit_cost * sd.quantity_sold), 0) AS cost_amount
            FROM sale_details sd
            JOIN sales s ON s.id = sd.sale_id
            WHERE \(interval.whereClause)
            """
        
        return try await db.readTransaction { tx in
            let amount = try tx.get(
                sql: sql,
                parameters: [dateString],
                mapper: { cursor in
                    try cursor.getInt(name: "cost_amount")
                }
            )
            return Money(amount)
        }
    }
    
    func getRevenueAmount(date: Date, interval: SalesDateInterval) async throws -> Money {
        let dateString = date.sqliteString()
        
        let sql = """
            SELECT COALESCE(SUM(sd.unit_price * sd.quantity_sold), 0) AS revenue_amount
            FROM sale_details sd
            JOIN sales s ON s.id = sd.sale_id
            WHERE \(interval.whereClause)
            """
        
        return try await db.readTransaction { tx in
            let amount = try tx.get(
                sql: sql,
                parameters: [dateString],
                mapper: { cursor in
                    try cursor.getInt(name: "revenue_amount")
                }
            )
            return Money(amount)
        }
    }
}

extension SalesDateInterval {
    var whereClause: String {
        switch self {
        case .diary: return "strftime('%Y-%m-%d', s.sale_date) = strftime('%Y-%m-%d', ?)"
        case .monthly: return "strftime('%Y-%m', s.sale_date) = strftime('%Y-%m', ?)"
        case .yearly: return "strftime('%Y', s.sale_date) = strftime('%Y', ?)"
        }
    }
}

extension Date {
    func sqliteString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter.string(from: self)
    }
}

extension SalesOrder {
    var orderByClause: String {
        switch self {
        case .dateAsc:
            return "MAX(s.sale_date) ASC"
        case .dateDesc:
            return "MAX(s.sale_date) DESC"
        case .quantityAsc:
            return "total_quantity ASC"
        case .quantityDesc:
            return "total_quantity DESC"
        case .incomeAsc:
            return "total_income ASC"
        case .incomeDesc:
            return "total_income DESC"
        }
    }
}

extension SalesOrder {
    var historicOrderByClause: String {
        switch self {
        case .dateAsc:
            return "s.sale_date ASC"
        case .dateDesc:
            return "s.sale_date DESC"
        case .quantityAsc:
            return "sd.quantity_sold ASC"
        case .quantityDesc:
            return "sd.quantity_sold DESC"
        case .incomeAsc:
            return "sd.subtotal ASC"
        case .incomeDesc:
            return "sd.subtotal DESC"
        }
    }
}
