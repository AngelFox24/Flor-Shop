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
    func registerSale(cart: Car?, customer: Customer?, paymentType: PaymentType) -> Bool
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
    let manager: SaleManager
    let remoteManager: RemoteSaleManager
    // let remote:  remoto, se puede implementar el remoto aqui
    init(manager: SaleManager) {
        self.manager = manager
        self.remoteManager = RemoteSaleManagerImpl()
    }
    func sync() async throws {
        print("Not implemented")
//        guard let subsidiaryId = manager.getDefaultSubsidiary()?.id else {
//            throw RepositoryError.invalidFields(("El campo subsidiaryId no esta configurado"))
//        }
//        var counter = 0
//        var items = 0
//        
//        repeat {
//            print("Counter: \(counter)")
//            counter += 1
//            guard let updatedSince = manager.getLastUpdated() else {
//                throw RepositoryError.invalidFields(("El campo updatedSince no se encuentra"))
//            }
//            let updatedSinceString = ISO8601DateFormatter().string(from: updatedSince)
//            let sales = try await self.remoteManager.sync(subsidiaryId: subsidiaryId, updatedSince: updatedSinceString)
//            items = products.count
//            print("Items Sync: \(items)")
//            for sale in sales {
//                manager.sav
//            }
//        } while (counter < 10 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
    }
    func registerSale(cart: Car?, customer: Customer?, paymentType: PaymentType) -> Bool {
        return self.manager.registerSale(cart: cart, customer: customer, paymentType: paymentType)
    }
    func payClientTotalDebt(customer: Customer) -> Bool {
        return self.manager.payClientTotalDebt(customer: customer)
    }
    func getListSales() -> [Sale] {
        // add to remote logic
        return self.manager.getListSales()
    }
    func setDefaultSubsidiary(subsidiary: Subsidiary) {
        self.manager.setDefaultSubsidiary(subsidiary: subsidiary)
    }
    func getDefaultSubsidiary() -> Subsidiary? {
        return self.manager.getDefaultSubsidiary()
    }
    func getListSalesDetailsHistoric(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) -> [SaleDetail] {
        return self.manager.getListSalesDetailsHistoric(page: page, pageSize: pageSize, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
    }
    func getListSalesDetailsGroupedByProduct(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) -> [SaleDetail] {
        return self.manager.getListSalesDetailsGroupedByProduct(page: page, pageSize: pageSize, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
    }
    func getListSalesDetailsGroupedByCustomer(page: Int, pageSize: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) -> [SaleDetail] {
        return self.manager.getListSalesDetailsGroupedByCustomer(page: page, pageSize: pageSize, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
    }
    func getSalesAmount(date: Date, interval: SalesDateInterval) -> Double {
        return self.manager.getSalesAmount(date: date, interval: interval)
    }
    func getCostAmount(date: Date, interval: SalesDateInterval) -> Double {
        return self.manager.getCostAmount(date: date, interval: interval)
    }
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Double {
        return self.manager.getRevenueAmount(date: date, interval: interval)
    }
    func releaseResourses() {
        self.manager.releaseResourses()
    }
}
