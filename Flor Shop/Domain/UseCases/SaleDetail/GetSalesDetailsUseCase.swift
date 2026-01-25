import Foundation

protocol GetSalesDetailsUseCase {
    func execute(page: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) async -> [SaleDetail]
}

final class GetSalesDetailsInteractor: GetSalesDetailsUseCase {
    private let saleRepository: SaleRepository
    
    init(saleRepository: SaleRepository) {
        self.saleRepository = saleRepository
    }
    
    func execute(page: Int, sale: Sale? = nil, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) async -> [SaleDetail] {
        do {
            switch grouper {
            case .historic:
                return try await self.saleRepository.getSalesDetailsHistoric(page: page, pageSize: 20, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
            case .byProduct:
                return try await self.saleRepository.getSalesDetailsGroupedByProduct(page: page, pageSize: 20, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
            case .byCustomer:
                return try await self.saleRepository.getSalesDetailsGroupedByCustomer(page: page, pageSize: 20, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
            }
        } catch {
            return []
        }
    }
}
