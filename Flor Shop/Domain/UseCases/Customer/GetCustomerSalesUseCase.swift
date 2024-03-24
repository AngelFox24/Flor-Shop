//
//  GetCustomerSalesUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 22/03/24.
//
import Foundation

protocol GetCustomerSalesUseCase {
    func execute(customer: Customer, page: Int) -> [SaleDetail]
}

final class GetCustomerSalesInteractor: GetCustomerSalesUseCase {
    
    private let customerRepository: CustomerRepository
    
    init(customerRepository: CustomerRepository) {
        self.customerRepository = customerRepository
    }
    
    func execute(customer: Customer, page: Int) -> [SaleDetail] {
        return self.customerRepository.getSalesDetailHistory(customer: customer, page: page, pageSize: 20)
    }
}
