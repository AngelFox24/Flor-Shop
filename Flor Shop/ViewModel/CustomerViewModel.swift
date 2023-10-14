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
    func filterCustomer(word: String) {
        if word == "" {
            fetchListCustomer()
        } else {
            customerList = self.customerRepository.filterCustomer(word: word)
        }
    }
    func setOrder(order: CustomerOrder) {
        customerRepository.setOrder(order: order)
    }
    func setFilter(filter: CustomerFilterAttributes) {
        customerRepository.setFilter(filter: filter)
    }
    func lazyFetchList() {
        if customerList.isEmpty {
            fetchListCustomer()
        }
    }
}
