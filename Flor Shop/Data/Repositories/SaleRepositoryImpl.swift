//
//  SaleRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

protocol SaleRepository {
    func sync() async throws
//    func save(customerId: UUID?, employeeId: UUID, sale: Sale) async throws
    func registerSale(cart: Car, paymentType: PaymentType, customerId: UUID?) async throws
    func payClientTotalDebt(customer: Customer) throws -> Bool
    func getListSales() -> [Sale]
    func getListSalesDetailsHistoric(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail]
    func getListSalesDetailsGroupedByProduct(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail]
    func getListSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail]
    func getSalesAmount(date: Date, interval: SalesDateInterval) throws -> Double
    func getCostAmount(date: Date, interval: SalesDateInterval) throws -> Double
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Double
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
            let _ = self.localManager.registerSale(cart: cart, paymentType: paymentType, customerId: customerId)
        }
    }
    func sync() async throws {
        var counter = 0
        var items = 0
        repeat {
            counter += 1
            let updatedSinceString = ISO8601DateFormatter().string(from: localManager.getLastUpdated())
            let salesDTOs = try await self.remoteManager.sync(updatedSince: updatedSinceString)
            items = salesDTOs.count
            print("Items Sync: \(items)")
            try self.localManager.sync(salesDTOs: salesDTOs)
        } while (counter < 10 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
    }
    func payClientTotalDebt(customer: Customer) throws -> Bool {
        return try self.localManager.payClientTotalDebt(customer: customer)
    }
    func getListSales() -> [Sale] {
        // add to remote logic
        return self.localManager.getListSales()
    }
    func getListSalesDetailsHistoric(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail] {
        return try self.localManager.getListSalesDetailsHistoric(page: page, pageSize: pageSize, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
    }
    func getListSalesDetailsGroupedByProduct(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail] {
        return try self.localManager.getListSalesDetailsGroupedByProduct(page: page, pageSize: pageSize, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
    }
    func getListSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) throws -> [SaleDetail] {
        return try self.localManager.getListSalesDetailsGroupedByCustomer(page: page, pageSize: pageSize, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
    }
    func getSalesAmount(date: Date, interval: SalesDateInterval) throws -> Double {
        return try self.localManager.getSalesAmount(date: date, interval: interval)
    }
    func getCostAmount(date: Date, interval: SalesDateInterval) throws -> Double {
        return try self.localManager.getCostAmount(date: date, interval: interval)
    }
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Double {
        return self.localManager.getRevenueAmount(date: date, interval: interval)
    }
}
