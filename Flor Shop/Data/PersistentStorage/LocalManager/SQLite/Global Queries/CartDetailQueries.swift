import Foundation
import PowerSync
import FlorShopDTOs

enum CartDetailQueries {
    static func getCartDetails(cartId: String, subsidiaryCic: String, tx: Transaction) throws -> [CartDetail] {
        let checkCartSQL = """
            SELECT
                cd.id,
                cd.product_cic,
                cd.quantity
            FROM cart_detail cd
            WHERE cd.cart_id = ?
            """
        
        return try tx.getAll(
            sql: checkCartSQL,
            parameters: [cartId],
            mapper: { cursor in
                let cartDetailId = try cursor.getString(name: "id")
                let productCic = try cursor.getString(name: "product_cic")
                let product = try ProductQueries.getProduct(productCic: productCic, subsidiaryCic: subsidiaryCic, tx: tx)
                guard let cartDetailIdAsUUID = UUID(uuidString: cartDetailId) else {
                    throw LocalStorageError.invalidInput("[CartDetailQueries] No se pudo obtener un UUID válido para el ID de detalle de carrito: \(cartDetailId)")
                }
                return try CartDetail(
                    id: cartDetailIdAsUUID,
                    quantity: cursor.getInt(name: "quantity"),
                    product: product
                )
            }
        )
    }
    static func getCartDetail(cartDetailId: String, subsidiaryCic: String, tx: Transaction) throws -> CartDetail? {
        let checkCartSQL = """
            SELECT cd.id, cd.quantity, cd.product_cic
            FROM cart_detail cd
            WHERE
              cd.id = ?
            LIMIT 1
            """
        
        return try tx.getOptional(
            sql: checkCartSQL,
            parameters: [cartDetailId],
            mapper: { cursor in
                let cartDetailId = try cursor.getString(name: "id")
                let productCic = try cursor.getString(name: "product_cic")
                let product = try ProductQueries.getProduct(productCic: productCic, subsidiaryCic: subsidiaryCic, tx: tx)
                guard let cartDetailIdAsUUID = UUID(uuidString: cartDetailId) else {
                    throw LocalStorageError.invalidInput("[CartDetailQueries] No se pudo obtener un UUID válido para el ID de detalle de carrito: \(cartDetailId)")
                }
                return try CartDetail(
                    id: cartDetailIdAsUUID,
                    quantity: cursor.getInt(name: "quantity"),
                    product: product
                )
            }
        )
    }
    static func getCartDetail(cartId: String, productCic: String, subsidiaryCic: String, tx: Transaction) throws -> CartDetail? {
        let checkCartSQL = """
            SELECT cd.id, cd.quantity, cd.product_cic
            FROM cart_detail cd
            WHERE
              cd.cart_id = ?
              AND cd.product_cic = ?
            LIMIT 1
            """
        
        return try tx.getOptional(
            sql: checkCartSQL,
            parameters: [cartId, productCic],
            mapper: { cursor in
                let cartDetailId = try cursor.getString(name: "id")
                let productCic = try cursor.getString(name: "product_cic")
                let product = try ProductQueries.getProduct(productCic: productCic, subsidiaryCic: subsidiaryCic, tx: tx)
                guard let cartDetailIdAsUUID = UUID(uuidString: cartDetailId) else {
                    throw LocalStorageError.invalidInput("[CartDetailQueries] No se pudo obtener un UUID válido para el ID de detalle de carrito: \(cartDetailId)")
                }
                return try CartDetail(
                    id: cartDetailIdAsUUID,
                    quantity: cursor.getInt(name: "quantity"),
                    product: product
                )
            }
        )
    }
    static func updateCartDetailAmount(cartDetailId: String, amount: Int, tx: Transaction) throws {
        let sql = """
            UPDATE cart_detail
            SET quantity = ?
            WHERE id = ?
            """
        let affectedRows = try tx.execute(
            sql: sql,
            parameters: [amount, cartDetailId]
        )
        
        if affectedRows == 0 {
            throw LocalStorageError.entityNotFound("[CartDetailQueries] Cart detail with ID '\(cartDetailId)' not found")
        }
    }
    static func insertCartDetail(cartId: String, productCic: String, tx: Transaction) throws {
        let sql = """
                INSERT INTO cart_detail (
                    id,
                    cart_id,
                    product_cic,
                    quantity
                ) VALUES (?, ?, ?, ?)
                """
        
        let cartDetailId = UUID().uuidString
        
        try tx.execute(
            sql: sql,
            parameters: [
                cartDetailId,
                cartId,
                productCic,
                1
            ]
        )
        
    }
    static func deleteCartDetail(cartDetailId: String, tx: Transaction) throws {
        let sql = """
                DELETE FROM cart_detail
                WHERE id = ?
                """
        
        let affectedRows = try tx.execute(
            sql: sql,
            parameters: [cartDetailId]
        )
        
        if affectedRows == 0 {
            throw LocalStorageError.entityNotFound(
                "[CartDetailQueries] Cart detail with ID '\(cartDetailId)' not found"
            )
        }
    }
}
