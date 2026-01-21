import Foundation
import PowerSync
import FlorShopDTOs

protocol LocalCartManager {
    func createCartIdNotExist() throws
    func getCart() throws -> Car
    func deleteCartDetail(cartDetail: CartDetail) throws
    func addProductToCart(productIn: Product) throws
    func changeProductAmountInCartDetail(productCic: String, amount: Int) throws
    func emptyCart() throws
    func getCartQuantity() throws -> Int
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
    func createCartIdNotExist() throws {
        
    }
    
    func getCart() throws -> Car {
        throw NSError(domain: "Not implemented", code: 0, userInfo: nil)
    }
    
    func deleteCartDetail(cartDetail: CartDetail) throws {
        throw NSError(domain: "Not implemented", code: 0, userInfo: nil)
    }
    
    func addProductToCart(productIn: Product) throws {
        throw NSError(domain: "Not implemented", code: 0, userInfo: nil)
    }
    
    func changeProductAmountInCartDetail(productCic: String, amount: Int) throws {
        throw NSError(domain: "Not implemented", code: 0, userInfo: nil)
    }
    
    func emptyCart() throws {
        throw NSError(domain: "Not implemented", code: 0, userInfo: nil)
    }
    
    func getCartQuantity() throws -> Int {
        throw NSError(domain: "Not implemented", code: 0, userInfo: nil)
    }
}
