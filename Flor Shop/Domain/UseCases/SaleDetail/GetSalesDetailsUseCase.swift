//
//  GetSalesDetailsUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 7/12/23.
//

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
        switch grouper {
        case .historic:
            return self.saleRepository.getListSalesDetailsHistoric(page: page, pageSize: 20, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
        case .byProduct:
            return self.saleRepository.getListSalesDetailsGroupedByProduct(page: page, pageSize: 20, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
        case .byCustomer:
            return self.saleRepository.getListSalesDetailsGroupedByCustomer(page: page, pageSize: 20, sale: sale, date: date, interval: interval, order: order, grouper: grouper)
        }
    }
}
