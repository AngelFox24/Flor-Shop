import Foundation
import CoreData

protocol SaleRepository: Syncronizable {
    func registerSale(cart: Car, paymentType: PaymentType, customerId: UUID?) async throws
    func getSalesDetailsHistoric(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail]
    func getSalesDetailsGroupedByProduct(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail]
    func getSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail]
    func getSalesAmount(date: Date, interval: SalesDateInterval) throws -> Money
    func getCostAmount(date: Date, interval: SalesDateInterval) throws -> Money
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Money
}

class SaleRepositoryImpl: SaleRepository {
    let localManager: LocalSaleManager
    let remoteManager: RemoteSaleManager
    let cloudBD = true
    init(
        localManager: LocalSaleManager,
        remoteManager: RemoteSaleManager
    ) {
        self.localManager = localManager
        self.remoteManager = remoteManager
    }
    func registerSale(cart: Car, paymentType: PaymentType, customerId: UUID?) async throws {
        if cloudBD {
            try await self.remoteManager.save(cart: cart, paymentType: paymentType, customerId: customerId)
        } else {
            try self.localManager.registerSale(cart: cart, paymentType: paymentType, customerId: customerId)
        }
    }
    func getLastToken() -> Int64 {
        return 0
    }
    func getLastToken(context: NSManagedObjectContext) -> Int64 {
        return self.localManager.getLastToken(context: context)
    }
    func sync(backgroundContext: NSManagedObjectContext, syncDTOs: SyncClientParameters) async throws {
        try self.localManager.sync(backgroundContext: backgroundContext, salesDTOs: syncDTOs.sales)
    }
    func getSalesDetailsHistoric(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail] {
        return try self.localManager.getSalesDetailsHistoric(page: page, pageSize: pageSize, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
    }
    func getSalesDetailsGroupedByProduct(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail] {
        return try self.localManager.getSalesDetailsGroupedByProduct(page: page, pageSize: pageSize, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
    }
    func getSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail] {
        return try self.localManager.getSalesDetailsGroupedByCustomer(page: page, pageSize: pageSize, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
    }
    func getSalesAmount(date: Date, interval: SalesDateInterval) throws -> Money {
        return try self.localManager.getSalesAmount(date: date, interval: interval)
    }
    func getCostAmount(date: Date, interval: SalesDateInterval) throws -> Money {
        return try self.localManager.getCostAmount(date: date, interval: interval)
    }
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Money {
        return self.localManager.getRevenueAmount(date: date, interval: interval)
    }
}
