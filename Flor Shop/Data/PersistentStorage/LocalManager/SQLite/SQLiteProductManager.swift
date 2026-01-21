import Foundation
import PowerSync
import FlorShopDTOs

protocol LocalProductManager {
    func getProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) async throws -> [Product]
    func updateProducts(products: [Product]) -> [Product]
    func getProduct(productCic: String) async throws -> Product
}

final class SQLiteProductManager: LocalProductManager {
    let sessionConfig: SessionConfig
    let db: PowerSyncDatabaseProtocol
    init(
        sessionConfig: SessionConfig,
        db: PowerSyncDatabaseProtocol
    ) {
        self.sessionConfig = sessionConfig
        self.db = db
    }
    func getProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) async throws -> [Product] {
        let trimmedText = seachText
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .split(separator: " ")
                .first
                .map(String.init) ?? ""
        
        var whereClauses: [String] = []
        var parameters: [Any] = []
        if !trimmedText.isEmpty {
            whereClauses.append("p.product_name LIKE ?")
            parameters.append("%\(trimmedText)%")
        }
        whereClauses.append(filterAttribute.whereClause)
        let whereSQL = whereClauses.isEmpty ? "" : "WHERE " + whereClauses.joined(separator: " AND ")
        let orderBySQL = primaryOrder.orderBySQL
        let offset = max(page - 1, 0) * pageSize
        let sql = """
                SELECT
                    p.id,
                    p.product_cic,
                    p.product_name,
                    p.bar_code,
                    p.unit_type,
                    p.image_url,
                    ps.active,
                    ps.quantity_stock,
                    ps.unit_cost,
                    ps.unit_price,
                    ps.expiration_date
                FROM products p
                JOIN product_subsidiary ps ON ps.product_id = p.id
                \(whereSQL)
                \(orderBySQL)
                LIMIT \(pageSize) OFFSET \(offset)
            """
            
            do {
                return try await db.getAll(
                    sql: sql,
                    parameters: parameters,
                    mapper: { cursor in
                        return try Product(
                            id: UUID(uuidString: cursor.getString(name: "id")) ?? UUID(),
                            productCic: cursor.getStringOptional(name: "product_cic"),
                            active: cursor.getBoolean(name: "active"),
                            barCode: cursor.getStringOptional(name: "bar_code"),
                            name: cursor.getString(name: "product_name"),
                            qty: cursor.getInt(name: "quantity_stock"),
                            unitType: UnitType(rawValue: cursor.getString(name: "unit_type")) ?? .unit,
                            unitCost: Money(cursor.getInt(name: "unit_cost")),
                            unitPrice: Money(cursor.getInt(name: "unit_price")),
                            expirationDate: cursor.getStringOptional(name: "expiration_date").flatMap { ISO8601DateFormatter().date(from: $0) },
                            imageUrl: cursor.getStringOptional(name: "image_url")
                        )
                    }
                )
            } catch {
                return []
            }
    }
    func updateProducts(products: [Product]) -> [Product] {
        []//TODO: Creo que se debe reemplazar con watch
    }
    func getProduct(productCic: String) async throws -> Product {
        let sql = """
        SELECT
            p.id,
            p.product_cic,
            p.product_name,
            p.bar_code,
            p.unit_type,
            p.image_url,
            ps.active,
            ps.quantity_stock,
            ps.unit_cost,
            ps.unit_price,
            ps.expiration_date
        FROM products p
        JOIN product_subsidiary ps ON ps.product_id = p.id
        WHERE p.product_cic = ?
        LIMIT 1
        """
        
        return try await db.get(
            sql: sql,
            parameters: [productCic],
            mapper: { cursor in
                return try Product(
                    id: UUID(uuidString: cursor.getString(name: "id")) ?? UUID(),
                    productCic: cursor.getStringOptional(name: "product_cic"),
                    active: cursor.getBoolean(name: "active"),
                    barCode: cursor.getStringOptional(name: "bar_code"),
                    name: cursor.getString(name: "product_name"),
                    qty: cursor.getInt(name: "quantity_stock"),
                    unitType: UnitType(rawValue: cursor.getString(name: "unit_type")) ?? .unit,
                    unitCost: Money(cursor.getInt(name: "unit_cost")),
                    unitPrice: Money(cursor.getInt(name: "unit_price")),
                    expirationDate: cursor
                        .getStringOptional(name: "expiration_date")
                        .flatMap { ISO8601DateFormatter().date(from: $0) },
                    imageUrl: cursor.getStringOptional(name: "image_url")
                )
            }
        )
    }
}

extension ProductsFilterAttributes {
    var whereClause: String {
        switch self {
        case .allProducts: return "ps.active = 1"
        case .outOfStock: return "ps.quantity_stock <= 0"
        case .productWithdrawn: return "ps.active = 0"
        }
    }
}

extension PrimaryOrder {
    var orderBySQL: String {
        switch self {
        case .nameAsc: return "ORDER BY p.product_name ASC"
        case .nameDesc: return "ORDER BY p.product_name DESC"
        case .priceAsc: return "ORDER BY ps.unit_price ASC"
        case .priceDesc: return "ORDER BY ps.unit_price DESC"
        case .quantityAsc: return "ORDER BY ps.quantity_stock ASC"
        case .quantityDesc: return "ORDER BY ps.quantity_stock DESC"
        }
    }
}
