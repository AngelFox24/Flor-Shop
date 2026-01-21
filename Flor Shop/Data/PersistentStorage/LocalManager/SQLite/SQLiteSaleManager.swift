import Foundation
import PowerSync
import FlorShopDTOs

protocol LocalSaleManager {
    func getSalesDetailsHistoric(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail]
    func getSalesDetailsGroupedByProduct(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail]
    func getSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail]
    func getSalesAmount(date: Date, interval: SalesDateInterval) throws -> Money
    func getCostAmount(date: Date, interval: SalesDateInterval) throws -> Money
    func getRevenueAmount(date: Date, interval: SalesDateInterval) throws -> Money
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
    func getSalesDetailsHistoric(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail] {
        []
    }
    
    func getSalesDetailsGroupedByProduct(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail] {
        []
    }
    
    func getSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail] {
        []
    }
    
    func getSalesAmount(date: Date, interval: SalesDateInterval) throws -> Money {
        throw NSError(domain: "Not implemented", code: 0, userInfo: nil)
    }
    
    func getCostAmount(date: Date, interval: SalesDateInterval) throws -> Money {
        throw NSError(domain: "Not implemented", code: 0, userInfo: nil)
    }
    
    func getRevenueAmount(date: Date, interval: SalesDateInterval) throws -> Money {
        throw NSError(domain: "Not implemented", code: 0, userInfo: nil)
    }
}
