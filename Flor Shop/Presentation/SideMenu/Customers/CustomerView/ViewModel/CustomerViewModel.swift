//
//  CustomerViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 2/10/23.
//

import Foundation
import Combine

class CustomerViewModel: ObservableObject {
    @Published var customerList: [Customer] = []
    @Published var searchWord: String = ""
    @Published var order: CustomerOrder = .nameAsc
    @Published var filter: CustomerFilterAttributes = .allCustomers
    
    private var currentPage: Int = 1
    private var lastCarge: Int = 0
    private var cancellableSet = Set<AnyCancellable>()
    
    private let getCustomersUseCase: GetCustomersUseCase
    
    init(getCustomersUseCase: GetCustomersUseCase) {
        self.getCustomersUseCase = getCustomersUseCase
        addSearchTextSuscriber()
    }
    // MARK: CRUD Core Data
    func fetchListCustomer(page: Int = 1) {
        if page == 1 {
            let customersNewCarge = self.getCustomersUseCase.execute(seachText: self.searchWord, order: self.order, filter: self.filter, page: self.currentPage)
            lastCarge = customersNewCarge.count
            self.customerList = customersNewCarge
        } else {
            if lastCarge > 0 {
                let customersNewCarge = self.getCustomersUseCase.execute(seachText: self.searchWord, order: self.order, filter: self.filter, page: self.currentPage)
                lastCarge = customersNewCarge.count
                self.customerList.append(contentsOf: customersNewCarge)
            }
        }
    }
    func fetchNextPage() {
        currentPage = currentPage + 1
        fetchListCustomer(page: currentPage)
    }
    func addSearchTextSuscriber() {
        $searchWord
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.currentPage = 1
                fetchListCustomer()
            })
            .store(in: &cancellableSet)
    }
    func setOrder(order: CustomerOrder) {
        self.order = order
    }
    func setFilter(filter: CustomerFilterAttributes) {
        self.filter = filter
    }
    func releaseResources() {
        print("Se elimino los customers de la lista")
        self.customerList = []
        self.currentPage = 1
        self.lastCarge = 0
    }
    func lazyFetchList() {
        if customerList.isEmpty {
            fetchListCustomer()
        }
    }
}
