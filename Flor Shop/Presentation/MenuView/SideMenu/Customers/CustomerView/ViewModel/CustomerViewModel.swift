import Foundation
import Combine

@Observable
final class CustomerViewModel {
    var searchText: String = ""
    var customerList: [Customer] = []
    var searchWord: String = "" {
        didSet {
            onSearchTextChanged()
        }
    }
    var order: CustomerOrder = .nameAsc
    var filter: CustomerFilterAttributes = .allCustomers
    //Pagination
    private var currentPage: Int = 1
    private var lastCarge: Int = 0
    private var cancellableSet = Set<AnyCancellable>()
    //Search vars
    private var searchTask: Task<Void, Never>? = nil
    //Dependencies
    private let getCustomersUseCase: GetCustomersUseCase
    private let setCustomerInCart: SetCustomerInCartUseCase
    
    init(
        getCustomersUseCase: GetCustomersUseCase,
        setCustomerInCart: SetCustomerInCartUseCase
    ) {
        self.getCustomersUseCase = getCustomersUseCase
        self.setCustomerInCart = setCustomerInCart
    }
    // MARK: CRUD Core Data
    func fetchListCustomer(page: Int = 1) async {
        if page == 1 {
            let customersNewCarge = await self.getCustomersUseCase.execute(seachText: self.searchWord, order: self.order, filter: self.filter, page: self.currentPage)
            lastCarge = customersNewCarge.count
            self.customerList = customersNewCarge
        } else {
            if lastCarge > 0 {
                let customersNewCarge = await self.getCustomersUseCase.execute(seachText: self.searchWord, order: self.order, filter: self.filter, page: self.currentPage)
                lastCarge = customersNewCarge.count
                self.customerList.append(contentsOf: customersNewCarge)
            }
        }
    }
    func fetchNextPage() async {
        currentPage = currentPage + 1
        await fetchListCustomer(page: currentPage)
    }
    func setCustomerInCart(customer: Customer) {
        guard let customerCic = customer.customerCic else {
            return
        }
        Task {
            await self.setCustomerInCart.execute(customerCic: customerCic)
        }
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
    func updateUI() {
        Task {
            await self.fetchListCustomer()
        }
    }
    private func onSearchTextChanged() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300)) // debounce manual
            self.currentPage = 1
            await fetchListCustomer()
        }
    }
}
