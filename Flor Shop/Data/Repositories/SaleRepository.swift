//
//  SaleRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

protocol SaleRepository {
    func registerSale(cart: Car, paymentType: PaymentType, customerId: UUID?) async throws
    func getSalesDetailsHistoric(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail]
    func getSalesDetailsGroupedByProduct(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail]
    func getSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail]
    func getSalesAmount(date: Date, interval: SalesDateInterval) throws -> Money
    func getCostAmount(date: Date, interval: SalesDateInterval) throws -> Money
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Money
}

class SaleRepositoryImpl: SaleRepository, Syncronizable {
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
    func sync(backgroundContext: NSManagedObjectContext, syncTokens: VerifySyncParameters) async throws -> VerifySyncParameters {
        var counter = 0
        var items = 0
        var responseSyncTokens = syncTokens
        repeat {
            counter += 1
            let updatedSince = self.localManager.getLastUpdated()
            let response = try await self.remoteManager.sync(updatedSince: updatedSince, syncTokens: responseSyncTokens)
            items = response.salesDTOs.count
            responseSyncTokens = response.syncIds
            print("Items Sync Sale: \(items)")
            try self.localManager.sync(backgroundContext: backgroundContext, salesDTOs: response.salesDTOs)
        } while (counter < 10 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
        return responseSyncTokens
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
