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
    func payClientTotalDebt(customer: Customer) -> Bool
    func getListSales() -> [Sale]
    func setDefaultSubsidiary(subsidiary: Subsidiary)
    func getDefaultSubsidiary() -> Subsidiary?
    func getListSalesDetailsHistoric(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) -> [SaleDetail]
    func getListSalesDetailsGroupedByProduct(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) -> [SaleDetail]
    func getListSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) -> [SaleDetail]
    func getSalesAmount(date: Date, interval: SalesDateInterval) -> Double
    func getCostAmount(date: Date, interval: SalesDateInterval) -> Double
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Double
    func releaseResourses()
}

class SaleRepositoryImpl: SaleRepository, Syncronizable {
    let localManager: SaleManager
    let remoteManager: RemoteSaleManager
    let cloudBD = true
    init(
        localProductManager: SaleManager,
        remoteProductManager: RemoteSaleManager
    ) {
        self.localManager = localProductManager
        self.remoteManager = remoteProductManager
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
            guard let updatedSince = localManager.getLastUpdated() else {
                throw RepositoryError.invalidFields(("El campo updatedSince no se encuentra"))
            }
            let updatedSinceString = ISO8601DateFormatter().string(from: updatedSince)
            let salesDTOs = try await self.remoteManager.sync(updatedSince: updatedSinceString)
            items = salesDTOs.count
            print("Items Sync: \(items)")
            try await self.localManager.sync(salesDTOs: salesDTOs)
        } while (counter < 10 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
    }
    func payClientTotalDebt(customer: Customer) -> Bool {
        return self.localManager.payClientTotalDebt(customer: customer)
    }
    func getListSales() -> [Sale] {
        // add to remote logic
        return self.localManager.getListSales()
    }
    func setDefaultSubsidiary(subsidiary: Subsidiary) {
        self.localManager.setDefaultSubsidiary(subsidiary: subsidiary)
    }
    func getDefaultSubsidiary() -> Subsidiary? {
        return self.localManager.getDefaultSubsidiary()
    }
    func getListSalesDetailsHistoric(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) -> [SaleDetail] {
        return self.localManager.getListSalesDetailsHistoric(page: page, pageSize: pageSize, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
    }
    func getListSalesDetailsGroupedByProduct(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) -> [SaleDetail] {
        return self.localManager.getListSalesDetailsGroupedByProduct(page: page, pageSize: pageSize, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
    }
    func getListSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) -> [SaleDetail] {
        return self.localManager.getListSalesDetailsGroupedByCustomer(page: page, pageSize: pageSize, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
    }
    func getSalesAmount(date: Date, interval: SalesDateInterval) -> Double {
        return self.localManager.getSalesAmount(date: date, interval: interval)
    }
    func getCostAmount(date: Date, interval: SalesDateInterval) -> Double {
        return self.localManager.getCostAmount(date: date, interval: interval)
    }
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Double {
        return self.localManager.getRevenueAmount(date: date, interval: interval)
    }
    func releaseResourses() {
        self.localManager.releaseResourses()
    }
}
