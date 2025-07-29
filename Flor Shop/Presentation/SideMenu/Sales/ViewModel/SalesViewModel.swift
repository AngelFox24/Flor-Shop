import Foundation

@Observable
class SalesViewModel {
    var salesDetailsList: [SaleDetail] = []
    
    var order: SalesOrder = .dateAsc
    var grouper: SalesGrouperAttributes = .byProduct
    
    var salesCurrentDateFilter: Date = Date.now
    var salesDateInterval: SalesDateInterval = .diary
    
    var salesAmount: Money = Money(0)
    var costAmount: Money = Money(0)
    var revenueAmount: Money = Money(0)
    
    private let calendario = Calendar.current
    private var currentPage: Int = 1
    private var lastCarge: Int = 0
    
    private let registerSaleUseCase: RegisterSaleUseCase
    private let getSalesUseCase: GetSalesUseCase
    private let getSalesDetailsUseCase: GetSalesDetailsUseCase
    
    init(registerSaleUseCase: RegisterSaleUseCase, getSalesUseCase: GetSalesUseCase, getSalesDetailsUseCase: GetSalesDetailsUseCase) {
        self.registerSaleUseCase = registerSaleUseCase
        self.getSalesUseCase = getSalesUseCase
        self.getSalesDetailsUseCase = getSalesDetailsUseCase
    }
    func fetchSalesDetailsList(page: Int = 1) {
        if page == 1 {
            let newCarge = self.getSalesDetailsUseCase.execute(page: page, sale: nil, date: salesCurrentDateFilter, interval: salesDateInterval, order: order, grouper: grouper)
            lastCarge = newCarge.count
            self.salesDetailsList = newCarge
        } else {
            if lastCarge > 0 {
                let newCarge = self.getSalesDetailsUseCase.execute(page: page, sale: nil, date: salesCurrentDateFilter, interval: salesDateInterval, order: order, grouper: grouper)
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
    func registerSale(cart: Car, customerId: UUID?, paymentType: PaymentType) async throws {
        try await self.registerSaleUseCase.execute(cart: cart, paymentType: paymentType, customerId: customerId)
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
        revenueAmount = Money(salesAmount.cents - costAmount.cents)
    }
    func releaseResources() {
        self.salesDetailsList = []
        
        self.order = .dateAsc
        self.grouper = .byProduct
        
        self.salesCurrentDateFilter = Date.now
        self.salesDateInterval = .diary
        
        self.salesAmount = Money(0)
        self.costAmount = Money(0)
        self.revenueAmount = Money(0)
    }
    func lazyFetchList() {
        if salesDetailsList.isEmpty {
            fetchSalesDetailsList()
            updateAmountsBar()
        }
    }
}
