import Foundation

protocol GetSalesDetailsUseCase {
    
    func execute(page: Int, sale: Sale?, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) -> [SaleDetail]
}

final class GetSalesDetailsInteractor: GetSalesDetailsUseCase {
    
    private let saleRepository: SaleRepository
    
    init(saleRepository: SaleRepository) {
        self.saleRepository = saleRepository
    }
    
    func execute(page: Int, sale: Sale? = nil, date: Date, interval: SalesDateInterval, order: SalesOrder, grouper: SalesGrouperAttributes) -> [SaleDetail] {
        do {
            switch grouper {
            case .historic:
                return try self.saleRepository.getSalesDetailsHistoric(page: page, pageSize: 20, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
            case .byProduct:
                return try self.saleRepository.getSalesDetailsGroupedByProduct(page: page, pageSize: 20, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
            case .byCustomer:
                return try self.saleRepository.getSalesDetailsGroupedByCustomer(page: page, pageSize: 20, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
            }
        } catch {
            return []
        }
    }
}
