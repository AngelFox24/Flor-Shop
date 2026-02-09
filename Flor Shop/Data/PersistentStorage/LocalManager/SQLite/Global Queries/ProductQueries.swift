import Foundation
import PowerSync
import FlorShopDTOs

enum ProductQueries {
    static func getProduct(productCic: String, subsidiaryCic: String, tx: Transaction) throws -> Product {
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
            WHERE p.product_cic = ? AND ps.subsidiary_cic = ?
            LIMIT 1
            """
        
        return try tx.get(
            sql: sql,
            parameters: [productCic, subsidiaryCic],
            mapper: { cursor in
                try Product(
                    id: UUID(uuidString: cursor.getString(name: "id"))!,
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
    static func getProductWithBarcode(barcode: String, subsidiaryCic: String, tx: Transaction) throws -> Product {
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
            WHERE p.bar_code = ? AND ps.subsidiary_cic = ?
            LIMIT 1
            """
        
        return try tx.get(
            sql: sql,
            parameters: [barcode, subsidiaryCic],
            mapper: { cursor in
                try Product(
                    id: UUID(uuidString: cursor.getString(name: "id"))!,
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
    static func getProductAmount(productCic: String, subsidiaryCic: String, tx: Transaction) throws -> Int {
        let sql = """
                SELECT
                    ps.quantity_stock
                FROM products p
                JOIN product_subsidiary ps ON ps.product_id = p.id
                WHERE p.product_cic = ? AND ps.subsidiary_cic = ?
                LIMIT 1
                """
        
        return try tx.get(
            sql: sql,
            parameters: [productCic, subsidiaryCic],
            mapper: { cursor in
                try cursor.getInt(name: "quantity_stock")
            }
        )
    }
    static func getProductAmountWithBarcode(barcode: String, subsidiaryCic: String, tx: Transaction) throws -> Int {
        let sql = """
                SELECT
                    ps.quantity_stock
                FROM products p
                JOIN product_subsidiary ps ON ps.product_id = p.id
                WHERE p.bar_code = ? AND ps.subsidiary_cic = ?
                LIMIT 1
                """
        
        return try tx.get(
            sql: sql,
            parameters: [barcode, subsidiaryCic],
            mapper: { cursor in
                try cursor.getInt(name: "quantity_stock")
            }
        )
    }
}
