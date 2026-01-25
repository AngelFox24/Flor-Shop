import Foundation

protocol GetSalesUseCase {
    func getSalesAmount(date: Date, interval: SalesDateInterval) async throws -> Money
    func getCostAmount(date: Date, interval: SalesDateInterval) async throws -> Money
    func getRevenueAmount(date: Date, interval: SalesDateInterval) async throws -> Money
}

final class GetSalesInteractor: GetSalesUseCase {
    
    private let saleRepository: SaleRepository
    
    init(saleRepository: SaleRepository) {
        self.saleRepository = saleRepository
    }
    
    func getSalesAmount(date: Date, interval: SalesDateInterval) async throws -> Money {
        return try await self.saleRepository.getSalesAmount(date: date, interval: interval)
    }
    func getCostAmount(date: Date, interval: SalesDateInterval) async throws -> Money {
        return try await self.saleRepository.getCostAmount(date: date, interval: interval)
    }
    func getRevenueAmount(date: Date, interval: SalesDateInterval) async throws -> Money {
        return try await self.saleRepository.getRevenueAmount(date: date, interval: interval)
    }
}
