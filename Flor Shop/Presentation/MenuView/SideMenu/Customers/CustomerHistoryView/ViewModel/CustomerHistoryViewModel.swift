import Foundation

@Observable
class CustomerHistoryViewModel {
    var customer: Customer?
    var salesDetail: [SaleDetail] = []
    
    private var currentPage: Int = 1
    private var lastCarge: Int = 0
    
    private let getCustomerSalesUseCase: GetCustomerSalesUseCase
    private let getCustomersUseCase: GetCustomersUseCase
    private let payClientDebtUseCase: PayClientDebtUseCase
    
    init(
        getCustomerSalesUseCase: GetCustomerSalesUseCase,
        getCustomersUseCase: GetCustomersUseCase,
        payClientDebtUseCase: PayClientDebtUseCase
    ) {
        self.getCustomerSalesUseCase = getCustomerSalesUseCase
        self.getCustomersUseCase = getCustomersUseCase
        self.payClientDebtUseCase = payClientDebtUseCase
    }
    // MARK: CRUD Core Data
    func fetchCustomerSalesDetail(page: Int = 1) async {
        if let customerNN = customer {
            if page == 1 {
                let newCarge = await self.getCustomerSalesUseCase.execute(customer: customerNN, page: page)
                lastCarge = newCarge.count
                self.salesDetail = newCarge
            } else {
                if lastCarge > 0 {
                    let newCarge = await self.getCustomerSalesUseCase.execute(customer: customerNN, page: page)
                    lastCarge = newCarge.count
                    self.salesDetail.append(contentsOf: newCarge)
                }
            }
        }
    }
    func payTotalAmount() async throws -> Bool {
        guard let customerNN = customer else {
            return false
        }
        return try await self.payClientDebtUseCase.total(customer: customerNN)
    }
    func loadCustomer(customerCic: String) async throws {
        
    }
    func setCustomerInContext(customer: Customer) async {
        self.customer = customer
        await fetchCustomerSalesDetail()
    }
    func fetchNextPage() async {
        currentPage = currentPage + 1
        await fetchCustomerSalesDetail(page: currentPage)
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
    func updateData() async {
        guard let customerCic = customer?.customerCic else {
            return
        }
        let customer = await self.getCustomersUseCase.getCustomer(customerCic: customerCic)
        await MainActor.run {
            self.customer = customer
            self.salesDetail = []
        }
        updateUI()
    }
    func updateUI() {
        Task {
            await fetchCustomerSalesDetail()
        }
    }
}
