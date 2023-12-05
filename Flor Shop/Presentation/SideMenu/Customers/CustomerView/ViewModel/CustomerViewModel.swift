//
//  CustomerViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 2/10/23.
//

import Foundation

class CustomerViewModel: ObservableObject {
    @Published var customerList: [Customer] = []
    @Published var searchWord: String = ""
    @Published var order: CustomerOrder = .nameAsc
    @Published var filter: CustomerFilterAttributes = .allCustomers
    private var currentPage: Int = 1
    private let getCustomersUseCase: GetCustomersUseCase
    init(getCustomersUseCase: GetCustomersUseCase) {
        self.getCustomersUseCase = getCustomersUseCase
    }
    // MARK: CRUD Core Data
    func fetchListCustomer() {
        customerList = self.getCustomersUseCase.execute(seachText: self.searchWord, order: self.order, filter: self.filter, page: self.currentPage)
    }
    func filterCustomer(word: String) {
        if word == "" {
            fetchListCustomer()
        } else {
            customerList = self.getCustomersUseCase.execute(seachText: self.searchWord, order: self.order, filter: self.filter, page: self.currentPage)
        }
    }
    func setOrder(order: CustomerOrder) {
        self.order = order
    }
    func setFilter(filter: CustomerFilterAttributes) {
        self.filter = filter
    }
    func lazyFetchList() {
        if customerList.isEmpty {
            fetchListCustomer()
        }
    }
}
