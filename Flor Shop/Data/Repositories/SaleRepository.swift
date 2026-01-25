import Foundation
import FlorShopDTOs

protocol SaleRepository {
    func registerSale(cart: Car, paymentType: PaymentType, customerCic: String?) async throws
    func getSalesDetailsHistoric(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) async throws -> [SaleDetail]
    func getSalesDetailsGroupedByProduct(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) async throws -> [SaleDetail]
    func getSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) async throws -> [SaleDetail]
    func getSalesAmount(date: Date, interval: SalesDateInterval) async throws -> Money
    func getCostAmount(date: Date, interval: SalesDateInterval) async throws -> Money
    func getRevenueAmount(date: Date, interval: SalesDateInterval) async throws -> Money
}

class SaleRepositoryImpl: SaleRepository {
    let localManager: LocalSaleManager
    let remoteManager: RemoteSaleManager
    let localCartManager: LocalCartManager
    let cloudBD = true
    init(
        localManager: LocalSaleManager,
        remoteManager: RemoteSaleManager,
        localCartManager: LocalCartManager
    ) {
        self.localManager = localManager
        self.remoteManager = remoteManager
        self.localCartManager = localCartManager
    }
    func registerSale(cart: Car, paymentType: PaymentType, customerCic: String?) async throws {
        if cloudBD {
            try await self.remoteManager.save(cart: cart, paymentType: paymentType, customerCic: customerCic)
            try await self.localCartManager.emptyCart()
        }
    }
    func getSalesDetailsHistoric(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) async throws -> [SaleDetail] {
        return try await self.localManager.getSalesDetailsHistoric(page: page, pageSize: pageSize, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
    }
    func getSalesDetailsGroupedByProduct(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) async throws -> [SaleDetail] {
        return try await self.localManager.getSalesDetailsGroupedByProduct(page: page, pageSize: pageSize, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
    }
    func getSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) async throws -> [SaleDetail] {
        return try await self.localManager.getSalesDetailsGroupedByCustomer(page: page, pageSize: pageSize, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
    }
    func getSalesAmount(date: Date, interval: SalesDateInterval) async throws -> Money {
        return try await self.localManager.getSalesAmount(date: date, interval: interval)
    }
    func getCostAmount(date: Date, interval: SalesDateInterval) async throws -> Money {
        return try await self.localManager.getCostAmount(date: date, interval: interval)
    }
    func getRevenueAmount(date: Date, interval: SalesDateInterval) async throws -> Money {
        return try await self.localManager.getRevenueAmount(date: date, interval: interval)
    }
}
