//
//  SaleRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

protocol SaleRepository {
    func registerSale(cart: Car?, customer: Customer?) -> Bool
    func getListSales() -> [Sale]
    func setDefaultSubsidiary(subsidiary: Subsidiary)
    func getDefaultSubsidiary() -> Subsidiary?
    func getListSalesDetails(page: Int, pageSize: Int, sale: Sale?) -> [SaleDetail]
    func getSalesAmount(date: Date, interval: SalesDateInterval) -> Double
    func getCostAmount(date: Date, interval: SalesDateInterval) -> Double
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Double
}

class SaleRepositoryImpl: SaleRepository {
    let manager: SaleManager
    // let remote:  remoto, se puede implementar el remoto aqui
    init(manager: SaleManager) {
        self.manager = manager
    }
    func registerSale(cart: Car?, customer: Customer?) -> Bool {
        return self.manager.registerSale(cart: cart, customer: customer)
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
    func getListSalesDetails(page: Int, pageSize: Int, sale: Sale?) -> [SaleDetail] {
        return self.manager.getListSalesDetails(page: page, pageSize: pageSize, sale: sale)
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
}
