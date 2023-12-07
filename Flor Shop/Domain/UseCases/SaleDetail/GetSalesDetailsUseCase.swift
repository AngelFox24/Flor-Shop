//
//  GetSalesDetailsUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 7/12/23.
//

import Foundation

protocol GetSalesDetailsUseCase {
    
    func execute(page: Int, sale: Sale?) -> [SaleDetail]
}

final class GetSalesDetailsInteractor: GetSalesDetailsUseCase {
    
    private let saleRepository: SaleRepository
    
    init(saleRepository: SaleRepository) {
        self.saleRepository = saleRepository
    }
    
    func execute(page: Int, sale: Sale?) -> [SaleDetail] {
        print("SalesDetailsPage: \(page)")
        return self.saleRepository.getListSalesDetails(page: page, pageSize: 12, sale: sale)
    }
}
