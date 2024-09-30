//
//  CustomerHistoryViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 22/03/24.
//
import CoreData
import Foundation

class CustomerHistoryViewModel: ObservableObject {
    @Published var customer: Customer?
    @Published var salesDetail: [SaleDetail] = []
    
    private var currentPage: Int = 1
    private var lastCarge: Int = 0
    
    private let getCustomerSalesUseCase: GetCustomerSalesUseCase
    private let getCustomersUseCase: GetCustomersUseCase
    private let payClientDebtUseCase: PayClientDebtUseCase
    
    init(getCustomerSalesUseCase: GetCustomerSalesUseCase, getCustomersUseCase: GetCustomersUseCase, payClientDebtUseCase: PayClientDebtUseCase) {
        self.getCustomerSalesUseCase = getCustomerSalesUseCase
        self.getCustomersUseCase = getCustomersUseCase
        self.payClientDebtUseCase = payClientDebtUseCase
    }
    // MARK: CRUD Core Data
    func fetchCustomerSalesDetail(page: Int = 1) {
        if let customerNN = customer {
            if page == 1 {
                let newCarge = self.getCustomerSalesUseCase.execute(customer: customerNN, page: page)
                lastCarge = newCarge.count
                self.salesDetail = newCarge
            } else {
                if lastCarge > 0 {
                    let newCarge = self.getCustomerSalesUseCase.execute(customer: customerNN, page: page)
                    lastCarge = newCarge.count
                    self.salesDetail.append(contentsOf: newCarge)
                }
            }
        }
    }
    func payTotalAmount() -> Bool{
        guard let customerNN = customer else {
            return false
        }
        return self.payClientDebtUseCase.total(customer: customerNN)
    }
    func setCustomerInContext(customer: Customer) {
        self.customer = customer
        fetchCustomerSalesDetail()
    }
    func fetchNextPage() {
        currentPage = currentPage + 1
        fetchCustomerSalesDetail(page: currentPage)
    }
    func shouldLoadData(salesDetail: SaleDetail) -> Bool {
        if self.salesDetail.isEmpty {
            return false
        } else {
            guard let last = self.salesDetail.last else { return false }
            return salesDetail == last
        }
    }
    func releaseResources() {
        //self.customer = nil
        self.salesDetail = []
    }
    func updateData() throws {
        guard let customerNN = customer else {
            return
        }
        self.customer = try self.getCustomersUseCase.getCustomer(customer: customerNN)
        self.salesDetail = []
        lazyFetch()
    }
    func lazyFetch() {
        if salesDetail.isEmpty {
            fetchCustomerSalesDetail()
        }
    }
}
