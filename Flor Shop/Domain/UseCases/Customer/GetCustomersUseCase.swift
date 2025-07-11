//
//  GetCustomersUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 5/12/23.
//

import Foundation

protocol GetCustomersUseCase {
    func execute(seachText: String, order: CustomerOrder, filter: CustomerFilterAttributes, page: Int) -> [Customer]
    func getCustomer(customer: Customer) throws -> Customer?
}

final class GetCustomersInteractor: GetCustomersUseCase {
    
    private let customerRepository: CustomerRepository
    
    init(customerRepository: CustomerRepository) {
        self.customerRepository = customerRepository
    }
    
    func execute(seachText: String, order: CustomerOrder, filter: CustomerFilterAttributes, page: Int) -> [Customer] {
        return self.customerRepository.getCustomers(seachText: seachText, order: order, filter: filter, page: page, pageSize: 20)
    }
    
    func getCustomer(customer: Customer) throws -> Customer? {
        return try self.customerRepository.getCustomer(customer: customer)
    }
}
