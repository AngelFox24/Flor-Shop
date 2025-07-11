//
//  GetSalesUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol GetSalesUseCase {
    func getSalesAmount(date: Date, interval: SalesDateInterval) -> Money
    func getCostAmount(date: Date, interval: SalesDateInterval) -> Money
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Money
}

final class GetSalesInteractor: GetSalesUseCase {
    
    private let saleRepository: SaleRepository
    
    init(saleRepository: SaleRepository) {
        self.saleRepository = saleRepository
    }
    
    func getSalesAmount(date: Date, interval: SalesDateInterval) -> Money {
        do {
            return try self.saleRepository.getSalesAmount(date: date, interval: interval)
        } catch {
            print("Error: \(error.localizedDescription)")
            return Money(0)
        }
    }
    func getCostAmount(date: Date, interval: SalesDateInterval) -> Money {
        do {
            return try self.saleRepository.getCostAmount(date: date, interval: interval)
        } catch {
            print("Error: \(error.localizedDescription)")
            return Money(0)
        }
    }
    func getRevenueAmount(date: Date, interval: SalesDateInterval) -> Money {
        return self.saleRepository.getRevenueAmount(date: date, interval: interval)
    }
}
