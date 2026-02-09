import Foundation

@Observable
final class CustomerHistoryViewModel {
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
        if let customerCic = customer?.customerCic {
            print("[CustomerHistoryViewModel] hay customerCic")
            if page == 1 {
                let newCarge = await self.getCustomerSalesUseCase.execute(customerCic: customerCic, page: page)
                lastCarge = newCarge.count
                self.salesDetail = newCarge
            } else {
                if lastCarge > 0 {
                    let newCarge = await self.getCustomerSalesUseCase.execute(customerCic: customerCic, page: page)
                    lastCarge = newCarge.count
                    self.salesDetail.append(contentsOf: newCarge)
                }
            }
        }
    }
    func loadCustomer(customerCic: String) async {
        if let customer = await self.getCustomersUseCase.getCustomer(customerCic: customerCic) {
            await MainActor.run {
                self.customer = customer
            }
        }
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
    func updateUI(customerCic: String) async {
        await self.loadCustomer(customerCic: customerCic)
        await self.fetchCustomerSalesDetail()
    }
}
