//
//  CustomerViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 2/10/23.
//

import Foundation

class CustomerViewModel: ObservableObject {
    @Published var customerList: [Customer] = []
    private let customerRepository: CustomerRepository
    init(customerRepository: CustomerRepository) {
        self.customerRepository = customerRepository
    }
    // MARK: CRUD Core Data
    func fetchListCustomer() {
        customerList = customerRepository.getCustomers()
    }
    func lazyFetchList() {
        if customerList.isEmpty {
            fetchListCustomer()
        }
    }
}
