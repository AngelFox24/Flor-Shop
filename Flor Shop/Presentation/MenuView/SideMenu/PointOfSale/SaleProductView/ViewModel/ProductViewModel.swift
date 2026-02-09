import Foundation

@Observable
final class ProductViewModel {
    var productsCoreData: [Product] = []
    var counter: Int = 0
    var searchText: String = "" {
        didSet {
            guard oldValue != searchText else { return }
            onSearchTextChanged()
        }
    }
    var primaryOrder: PrimaryOrder = .nameAsc
    var filterAttribute: ProductsFilterAttributes = .allProducts
    var cartCount: Int = 0
    //Pagination vars
    var deleteCount: Int = 0
    private var currentPagesInScreen: [[Int]] = []
    private let maxPagesToLoad: Int = 3
    private var lastCarge: Int = 0
    //Search vars
    private var searchTask: Task<Void, Never>? = nil
    
    private let getProductsUseCase: GetProductsUseCase
    private let addProductoToCartUseCase: AddProductoToCartUseCase
    
    init(
        getProductsUseCase: GetProductsUseCase,
        addProductoToCartUseCase: AddProductoToCartUseCase
    ) {
        self.getProductsUseCase = getProductsUseCase
        self.addProductoToCartUseCase = addProductoToCartUseCase
    }
    func updateCartQuantity() async {
        do {
            let quatity = try await self.addProductoToCartUseCase.getCartQuantity()
            await MainActor.run {
                self.cartCount = quatity
                print("[ProductViewModel] Cart quantity: \(self.cartCount, default: "nil")")
            }
        } catch {
            await MainActor.run {
                self.cartCount = 0
            }
        }
    }
    func fetchProducts(page: Int = 1, nextPage: Bool = true, forceUpdate: Bool = false) async throws {
        if forceUpdate {
            await MainActor.run {
                self.productsCoreData = []
            }
        }
        let pages = currentPagesInScreen.map { $0[0] }
        if !pages.contains(page) || forceUpdate {
            let productsNewCarge = try await self.getProductsUseCase.execute(seachText: searchText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page)
//            print("[ProductViewModel] START FETCH PRODUCTS")
//            for product in productsNewCarge {
//                print("[ProductViewModel] Name: \(product) | Id: \(product.id.uuidString)")
//            }
//            print("[ProductViewModel] END FETCH PRODUCTS")
            lastCarge = productsNewCarge.count
            if lastCarge > 0 {
                if nextPage {
                    self.currentPagesInScreen.append([page, lastCarge])
                    await MainActor.run {
                        self.productsCoreData.append(contentsOf: productsNewCarge)
                    }
                } else {
                    self.currentPagesInScreen.insert(contentsOf: [[page, lastCarge]], at: 0)
                    await MainActor.run {
                        self.productsCoreData.insert(contentsOf: productsNewCarge, at: 0)
                    }
                }
            }
        }
    }
    func fetchNextPage() async throws {
        guard let firstCharge = self.currentPagesInScreen.first?[1] else { return }
        guard let lastPage = self.currentPagesInScreen.last?[0] else { return }
        try await fetchProducts(page: lastPage + 1)
        if lastCarge > 0 {
            if self.currentPagesInScreen.count > self.maxPagesToLoad {
                await MainActor.run {
                    self.deleteCount = self.deleteCount + firstCharge
                    self.productsCoreData.removeFirst(firstCharge)
                }
                self.currentPagesInScreen.removeFirst()
            }
        }
//        print("CurrentPagesInScreen: \(currentPagesInScreen.description)")
//        print("CurrentPagesInScreenCount: \(currentPagesInScreen.count.description)")
//        print("ProductsCoreData: \(productsCoreData.count.description)")
    }
    func fetchPreviousPage() async throws {
        guard let firstCharge = self.currentPagesInScreen.first?[1] else { return }
        guard let firstPage = self.currentPagesInScreen.first?[0] else { return }
        guard let lastCharge = self.currentPagesInScreen.last?[1] else { return }
        let previousPage = firstPage - 1
        if previousPage >= 1 {
            try await fetchProducts(page: previousPage, nextPage: false)
            if lastCarge > 0 {
                if self.currentPagesInScreen.count > self.maxPagesToLoad {
                    self.deleteCount = self.deleteCount - firstCharge
                    await MainActor.run {
                        self.productsCoreData.removeLast(lastCharge)
                    }
                    self.currentPagesInScreen.removeLast()
                } else {
                    self.deleteCount = 0
                }
            }
        }
//        print("CurrentPagesInScreen: \(currentPagesInScreen.description)")
//        print("CurrentPagesInScreenCount: \(currentPagesInScreen.count.description)")
//        print("ProductsCoreData: \(productsCoreData.count.description)")
    }
    func addProductoToCarrito(productCic: String) async throws {
        try await self.addProductoToCartUseCase.execute(productCic: productCic)
    }
    func shouldLoadData(product: Product) async throws {
        if self.productsCoreData.isEmpty {
            return
        } else {
            guard let lastProduct = self.productsCoreData.last else { return }
            guard let firstProduct = self.productsCoreData.first else { return }
            if product.id == lastProduct.id {
                try await fetchNextPage()
            } else if product.id == firstProduct.id {
                try await fetchPreviousPage()
            }
        }
    }
    func releaseResources() async {
        await MainActor.run {
            self.productsCoreData = []
            //self.searchText = ""
            //self.primaryOrder = .nameAsc
            //self.filterAttribute: ProductsFilterAttributes = .allProducts
            self.deleteCount = 0
            self.currentPagesInScreen = []
            self.lastCarge = 0
        }
    }
    private func onSearchTextChanged() {
        searchTask?.cancel()
        searchTask = Task {
            await releaseResources()
            do {
                try await Task.sleep(for: .seconds(0.3))
                try Task.checkCancellation()
                try await fetchProducts()
            } catch {
                return
            }
        }
    }
}
