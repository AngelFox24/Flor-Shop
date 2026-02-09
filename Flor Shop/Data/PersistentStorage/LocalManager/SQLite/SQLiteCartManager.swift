import Foundation
import PowerSync
import FlorShopDTOs

enum TypeOfVariation {
    case increase
    case decrease
}

protocol LocalCartManager {
    func initializeModel() async throws
    func getCart() async throws -> Car
    func deleteCartDetail(cartDetailId: UUID) async throws
    func addProductToCart(productCic: String) async throws
    func addProductWithBarcode(barcode: String) async throws
    func stepProductAmountInCartDetail(cartDetailId: UUID, type: TypeOfVariation) async throws
    func changeProductAmountInCartDetail(cartDetailId: UUID, amount: Int) async throws
    func emptyCart() async throws
    func getCartQuantity() async throws -> Int
    func setCustomerInCart(customerCic: String?) async throws
}

final class SQLiteCartManager: LocalCartManager {
    let sessionConfig: SessionConfig
    let db: PowerSyncDatabaseProtocol
    init(
        sessionConfig: SessionConfig,
        db: PowerSyncDatabaseProtocol
    ) {
        self.sessionConfig = sessionConfig
        self.db = db
    }
    func initializeModel() async throws {
        return try await self.db.writeTransaction { tx in
            try self.createCartModel(tx: tx)
            try self.createCartDetailModel(tx: tx)
            try self.createCartIfNotExists(tx: tx)
            let tables = try tx.getAll(
                sql: "SELECT name FROM sqlite_master WHERE type='table'",
                parameters: [],
                mapper: { cursor in
                    try cursor.getString(name: "name")
                }
            )
            print("[SQLiteCartManager] tablas: \(tables)")
        }
    }
    
    func getCart() async throws -> Car {
        return try await self.db.readTransaction { tx in
            return try CartQueries.getCart(
                employeeCic: self.sessionConfig.employeeCic,
                subsidiaryCic: self.sessionConfig.subsidiaryCic,
                tx: tx
            )
        }
    }
    
    func deleteCartDetail(cartDetailId: UUID) async throws {
        return try await self.db.writeTransaction { tx in
            try CartDetailQueries.deleteCartDetail(cartDetailId: cartDetailId.uuidString, tx: tx)
        }
    }
    
    func addProductToCart(productCic: String) async throws {
        return try await self.db.writeTransaction { tx in
            let productAmount = try ProductQueries.getProductAmount(productCic: productCic, subsidiaryCic: self.sessionConfig.subsidiaryCic, tx: tx)
            guard productAmount > 0 else {
                throw LocalStorageError.invalidInput("[SQLiteCartManager] El producto no tiene stock")
            }
            let cart = try self.getCartWithoutDetails(tx: tx)
            if let cartDetail = try CartDetailQueries.getCartDetail(
                cartId: cart.id.uuidString,
                productCic: productCic,
                subsidiaryCic: self.sessionConfig.subsidiaryCic,
                tx: tx
            ) {
                try self.changeProductAmountInCartDetail(
                    cartDetailId: cartDetail.id.uuidString,
                    amount: cartDetail.quantity + 1,
                    tx: tx
                )
            } else {
                try CartDetailQueries.insertCartDetail(cartId: cart.id.uuidString, productCic: productCic, tx: tx)
            }
        }
    }
    
    func addProductWithBarcode(barcode: String) async throws {
        return try await self.db.writeTransaction { tx in
            let product = try ProductQueries.getProductWithBarcode(barcode: barcode, subsidiaryCic: self.sessionConfig.subsidiaryCic, tx: tx)
            guard let productCic = product.productCic,
                  product.qty > 0 else {
                throw LocalStorageError.invalidInput("[SQLiteCartManager] El producto no tiene stock")
            }
            let cart = try self.getCartWithoutDetails(tx: tx)
            if let cartDetail = try CartDetailQueries.getCartDetail(
                cartId: cart.id.uuidString,
                productCic: productCic,
                subsidiaryCic: self.sessionConfig.subsidiaryCic,
                tx: tx
            ) {
                try self.changeProductAmountInCartDetail(
                    cartDetailId: cartDetail.id.uuidString,
                    amount: cartDetail.quantity + 1,
                    tx: tx
                )
            } else {
                try CartDetailQueries.insertCartDetail(cartId: cart.id.uuidString, productCic: productCic, tx: tx)
            }
        }
    }
    
    func stepProductAmountInCartDetail(cartDetailId: UUID, type: TypeOfVariation) async throws {
        try await self.db.writeTransaction { tx in
            if let cartDetail = try CartDetailQueries.getCartDetail(
                cartDetailId: cartDetailId.uuidString,
                subsidiaryCic: self.sessionConfig.subsidiaryCic,
                tx: tx
            ) {
                let unitType = cartDetail.product.unitType
                let amountVariation: Int
                switch unitType {
                case .unit:
                    amountVariation = 1
                case .kilo:
                    amountVariation = 100
                }
                let newAmount: Int
                switch type {
                case .increase:
                    newAmount = cartDetail.quantity + amountVariation
                case .decrease:
                    newAmount = cartDetail.quantity - amountVariation
                }
                if newAmount <= 0 {
                    try CartDetailQueries.deleteCartDetail(cartDetailId: cartDetailId.uuidString, tx: tx)
                } else {
                    try self.changeProductAmountInCartDetail(cartDetailId: cartDetailId.uuidString, amount: newAmount, tx: tx)
                }
            }
        }
    }
    
    func changeProductAmountInCartDetail(cartDetailId: UUID, amount: Int) async throws {
        try await self.db.writeTransaction { tx in
            try self.changeProductAmountInCartDetail(cartDetailId: cartDetailId.uuidString, amount: amount, tx: tx)
        }
    }
    
    func emptyCart() async throws {
        try await self.db.writeTransaction { tx in
            let cart = try CartQueries.getCart(
                employeeCic: self.sessionConfig.employeeCic,
                subsidiaryCic: self.sessionConfig.subsidiaryCic,
                tx: tx
            )
            for cartDetail in cart.cartDetails {
                try CartDetailQueries.deleteCartDetail(cartDetailId: cartDetail.id.uuidString, tx: tx)
            }
        }
    }
    
    func getCartQuantity() async throws -> Int {
        return try await self.db.readTransaction { tx in
            let cart = try self.getCartWithoutDetails(tx: tx)
            return try CartQueries.getCartQuantity(cartId: cart.id.uuidString, tx: tx)
        }
    }
    
    func setCustomerInCart(customerCic: String?) async throws {
        try await self.db.writeTransaction { tx in
            let cart = try self.getCartWithoutDetails(tx: tx)
            let sql = """
                    UPDATE cart
                    SET customer_cic = ?
                    WHERE id = ?
                    """
            
            let rows = try tx.execute(
                sql: sql,
                parameters: [
                    customerCic,
                    cart.id.uuidString
                ]
            )
            
            if rows == 0 {
                throw LocalStorageError.entityNotFound(
                    "[SQLiteCartManager] No se encontró el carrito para asignar cliente"
                )
            }
        }
    }
    //MARK: Private funtions
    private func createCartModel(tx: Transaction) throws {
        let sql = """
            CREATE TABLE IF NOT EXISTS cart (
                id TEXT PRIMARY KEY,
                employee_cic TEXT NOT NULL,
                subsidiary_cic TEXT NOT NULL,
                customer_cic TEXT
            );
            """
        try tx.execute(sql: sql, parameters: [])
    }
    private func createCartDetailModel(tx: Transaction) throws {
        let sql = """
            CREATE TABLE IF NOT EXISTS cart_detail (
                id TEXT PRIMARY KEY,
                cart_id TEXT NOT NULL,
                product_cic TEXT NOT NULL,
                quantity INTEGER NOT NULL,
                UNIQUE (cart_id, product_cic)
            );
            """
        try tx.execute(sql: sql, parameters: [])
    }
    private func changeProductAmountInCartDetail(cartDetailId: String, amount: Int, tx: Transaction) throws {
        if let cartDetail = try CartDetailQueries.getCartDetail(
            cartDetailId: cartDetailId,
            subsidiaryCic: self.sessionConfig.subsidiaryCic,
            tx: tx
        ) {
            guard amount >= 0 else {
                throw LocalStorageError.invalidInput("El producto no puede tener una cantidad negativa")
            }
            if cartDetail.product.qty >= amount {
                try CartDetailQueries.updateCartDetailAmount(cartDetailId: cartDetail.id.uuidString, amount: amount, tx: tx)
            } else {
                print("Producto no tiene stock suficiente")
                throw BusinessLogicError.outOfStock("Producto no tiene stock suficiente")
            }
        }
    }
    private func createCartIfNotExists(tx: Transaction) throws {
        let checkCartSQL = """
            SELECT id
            FROM cart
            WHERE employee_cic = ? AND subsidiary_cic = ?
            LIMIT 1
            """
        if let _ = try tx.getOptional(
            sql: checkCartSQL,
            parameters: [self.sessionConfig.employeeCic, self.sessionConfig.subsidiaryCic],
            mapper: { cursor in
                let cartId = try cursor.getString(name: "id")
                guard let uuid = UUID(uuidString: cartId) else {
                    throw NSError(domain: "InvalidCartId", code: 0)
                }
                return Car(
                    id: uuid,
                    cartDetails: [],
                    customerCic: nil
                )
            }
        ) {
            print("[SQLiteCartManager] Cart already exists")
            return
        } else {
            print("[SQLiteCartManager] Creating new cart")
            try self.insertEmptyCart(tx: tx)
        }
    }
    private func getCartWithoutDetails(tx: Transaction) throws -> Car {
        let sql = """
            SELECT id
            FROM cart
            WHERE employee_cic = ? AND subsidiary_cic = ?
            LIMIT 1
            """
        let cart = try tx.get(
            sql: sql,
            parameters: [self.sessionConfig.employeeCic, self.sessionConfig.subsidiaryCic],
            mapper: { cursor in
                let cartId = try cursor.getString(name: "id")
                guard let uuid = UUID(uuidString: cartId) else {
                    throw NSError(domain: "InvalidCartId", code: 0)
                }
                return Car(
                    id: uuid,
                    cartDetails: [],
                    customerCic: nil
                )
            }
        )
        return cart
    }
    private func insertEmptyCart(tx: Transaction) throws {
        let cartId = UUID()
        
        let insertCartSQL = """
            INSERT INTO cart (id, employee_cic, subsidiary_cic)
            VALUES (?, ?, ?)
            """
        
        try tx.execute(
            sql: insertCartSQL,
            parameters: [cartId.uuidString, self.sessionConfig.employeeCic, self.sessionConfig.subsidiaryCic]
        )
    }
}
