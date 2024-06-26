//
//  GetSalesUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol GetSalesUseCase {
    func execute(page: Int) -> [Sale]
    func getSalesAmount(date: Date, interval: SalesDateInterval) -> Double
    func getCostAmount(date: Date, interval: SalesDateInterval) -> Double
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Double
}

final class GetSalesInteractor: GetSalesUseCase {
    
    private let saleRepository: SaleRepository
    
    init(saleRepository: SaleRepository) {
        self.saleRepository = saleRepository
    }
    
    func execute(page: Int) -> [Sale] {
        return self.saleRepository.getListSales()
    }
    
    func getSalesAmount(date: Date, interval: SalesDateInterval) -> Double {
        return self.saleRepository.getSalesAmount(date: date, interval: interval)
    }
    func getCostAmount(date: Date, interval: SalesDateInterval) -> Double {
        return self.saleRepository.getCostAmount(date: date, interval: interval)
    }
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Double {
        return self.saleRepository.getRevenueAmount(date: date, interval: interval)
    }
}
