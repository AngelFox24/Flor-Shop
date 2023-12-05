//
//  GetSalesUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol GetSalesUseCase {
    
    func execute(page: Int) -> [Sale]
}

final class GetSalesInteractor: GetSalesUseCase {
    
    private let saleRepository: SaleRepository
    
    init(saleRepository: SaleRepository) {
        self.saleRepository = saleRepository
    }
    
    func execute(page: Int) -> [Sale] {
        return self.saleRepository.getListSales()
    }
}
