//
//  VentasCoreDataViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 8/05/23.
//
import CoreData
import Foundation

class SalesViewModel: ObservableObject {
    @Published var salesList: [Sale] = []
    @Published var salesDetailsList: [SaleDetail] = []
    @Published var salesCurrentDateFilter: Date = Date.now
    @Published var salesDateInterval: SalesDateInterval = .diary
    @Published var order: SalesOrder = .dateAsc
    @Published var filterAttribute: SalesFilterAttributes = .byProduct
    @Published var salesAmount: Double = 0.0
    @Published var costAmount: Double = 0.0
    @Published var revenueAmount: Double = 0.0
    let calendario = Calendar.current
    private var currentPage: Int = 1
    private var lastCarge: Int = 0
    
    let registerSaleUseCase: RegisterSaleUseCase
    let getSalesUseCase: GetSalesUseCase
    let getSalesDetailsUseCase: GetSalesDetailsUseCase
    
    init(registerSaleUseCase: RegisterSaleUseCase, getSalesUseCase: GetSalesUseCase, getSalesDetailsUseCase: GetSalesDetailsUseCase) {
        self.registerSaleUseCase = registerSaleUseCase
        self.getSalesUseCase = getSalesUseCase
        self.getSalesDetailsUseCase = getSalesDetailsUseCase
    }
    func fetchSalesDetailsList(page: Int = 1) {
        if page == 1 {
            let newCarge = self.getSalesDetailsUseCase.execute(page: page, sale: nil, date: salesCurrentDateFilter, interval: salesDateInterval)
            lastCarge = newCarge.count
            self.salesDetailsList = newCarge
        } else {
            if lastCarge > 0 {
                let newCarge = self.getSalesDetailsUseCase.execute(page: page, sale: nil, date: salesCurrentDateFilter, interval: salesDateInterval)
                lastCarge = newCarge.count
                self.salesDetailsList.append(contentsOf: newCarge)
            }
        }
    }
    func fetchSalesDetailsListNextPage() {
        currentPage = currentPage + 1
        fetchSalesDetailsList(page: currentPage)
    }
    func shouldSalesDetailsListLoadData(saleDetail: SaleDetail) -> Bool {
        if self.salesDetailsList.isEmpty {
            return false
        } else {
            guard let lastSaleDetail = self.salesDetailsList.last else { return false }
            print("In: \(saleDetail.id) Comp: \(lastSaleDetail.id)")
            print("TotalListDetail: \(self.salesDetailsList.count)")
            return saleDetail == lastSaleDetail
        }
    }
    func registerSale(cart: Car?, customer: Customer?) -> Bool {
        return self.registerSaleUseCase.execute(cart: cart, customer: customer)
    }
    func nextDate() {
        switch salesDateInterval {
        case .diary:
            salesCurrentDateFilter = calendario.date(byAdding: .day, value: 1, to: salesCurrentDateFilter)!
        case .monthly:
            salesCurrentDateFilter = calendario.date(byAdding: .month, value: 1, to: salesCurrentDateFilter)!
        case .yearly:
            salesCurrentDateFilter = calendario.date(byAdding: .year, value: 1, to: salesCurrentDateFilter)!
        }
    }
    func previousDate() {
        switch salesDateInterval {
        case .diary:
            salesCurrentDateFilter = calendario.date(byAdding: .day, value: -1, to: salesCurrentDateFilter)!
        case .monthly:
            salesCurrentDateFilter = calendario.date(byAdding: .month, value: -1, to: salesCurrentDateFilter)!
        case .yearly:
            salesCurrentDateFilter = calendario.date(byAdding: .year, value: -1, to: salesCurrentDateFilter)!
        }
    }
    func updateAmountsBar() {
        salesAmount = self.getSalesUseCase.getSalesAmount(date: salesCurrentDateFilter, interval: salesDateInterval)
        costAmount = self.getSalesUseCase.getCostAmount(date: salesCurrentDateFilter, interval: salesDateInterval)
        revenueAmount = salesAmount - costAmount
    }
    func lazyFetchList() {
        if salesList.isEmpty {
            fetchSalesDetailsList()
            updateAmountsBar()
        }
    }
}
