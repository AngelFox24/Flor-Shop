import Foundation
import PowerSync
import FlorShopDTOs

enum CartQueries {
    static func getCart(employeeCic: String, subsidiaryCic: String, tx: Transaction) throws -> Car {
        let checkCartSQL = """
            SELECT c.id, c.customer_cic
            FROM cart c
            WHERE c.employee_cic = ? AND c.subsidiary_cic = ?
            LIMIT 1
            """
        
        return try tx.get(
            sql: checkCartSQL,
            parameters: [employeeCic, subsidiaryCic],
            mapper: { cursor in
                let cartId = try cursor.getString(name: "id")
                guard let uuid = UUID(uuidString: cartId) else {
                    throw NSError(domain: "InvalidCartId", code: 0)
                }
                return try Car(
                    id: uuid,
                    cartDetails: CartDetailQueries.getCartDetails(cartId: cartId, subsidiaryCic: subsidiaryCic, tx: tx),
                    customerCic: cursor.getStringOptional(name: "customer_cic")
                )
            }
        )
    }
    static func getCartQuantity(cartId: String, tx: Transaction) throws -> Int {
        let sql = """
          SELECT COUNT(*) AS total_items
          FROM cart_detail
          WHERE cart_id = ?
          """
        
        return try tx.get(
            sql: sql,
            parameters: [cartId],
            mapper: { cursor in
                try cursor.getInt(name: "total_quantity")
            }
        )
    }
}
