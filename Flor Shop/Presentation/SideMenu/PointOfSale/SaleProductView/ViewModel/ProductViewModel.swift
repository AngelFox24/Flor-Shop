import Foundation

@Observable
class ProductViewModel {
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
    var deleteCount: Int = 0
    //Sync Engine
    private var lastToken: Int64
    //Pagination vars
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
        self.lastToken = self.getProductsUseCase.getLastToken()
    }
    //Old
    func updateCurrentListOld(newToken: Int64) async {
        if lastToken < newToken {
            let productsUpdated = self.getProductsUseCase.updateProducts(products: self.productsCoreData)
            await MainActor.run {
                for productUpdated in productsUpdated {
                    if let index = self.productsCoreData.firstIndex(where: { $0.id == productUpdated.id }) {
                        print("[FlorShop] Se cambiara: \(productsCoreData[index].name), price: \(productsCoreData[index].unitPrice.solesString)")
                        self.productsCoreData[index] = productUpdated
                        print("[FlorShop] Se cambio: \(productsCoreData[index].name), price: \(productsCoreData[index].unitPrice.solesString)")
                    }
                }
                self.lastToken = self.getProductsUseCase.getLastToken()
            }
        }
    }
    //New, TODO: verificar si no hay problemas con el scroll
    func updateCurrentList(newToken: Int64) async {
        guard let lastPage = self.currentPagesInScreen.last?[0] else { return }
        if lastToken < newToken {
            let productsUpdated = self.getProductsUseCase.execute(seachText: searchText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: lastPage)
            await MainActor.run {
                self.productsCoreData = productsUpdated
                self.lastToken = newToken
            }
        }
    }
    func fetchProducts(page: Int = 1, nextPage: Bool = true) async {
        let pages = currentPagesInScreen.map { $0[0] }
        if !pages.contains(page) {
            let productsNewCarge = self.getProductsUseCase.execute(seachText: searchText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page)
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
    func fetchNextPage() async {
        guard let firstCharge = self.currentPagesInScreen.first?[1] else { return }
        guard let lastPage = self.currentPagesInScreen.last?[0] else { return }
        await fetchProducts(page: lastPage + 1)
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
    func fetchPreviousPage() async {
        guard let firstCharge = self.currentPagesInScreen.first?[1] else { return }
        guard let firstPage = self.currentPagesInScreen.first?[0] else { return }
        guard let lastCharge = self.currentPagesInScreen.last?[1] else { return }
        let previousPage = firstPage - 1
        if previousPage >= 1 {
            await fetchProducts(page: previousPage, nextPage: false)
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
    func addProductoToCarrito(product: Product) async throws {
        try self.addProductoToCartUseCase.execute(product: product)
    }
    func shouldLoadData(product: Product) async {
        if self.productsCoreData.isEmpty {
            return
        } else {
            guard let lastProduct = self.productsCoreData.last else { return }
            guard let firstProduct = self.productsCoreData.first else { return }
            if product.id == lastProduct.id {
                await fetchNextPage()
            } else if product.id == firstProduct.id {
                await fetchPreviousPage()
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
    func lazyFetchProducts() async {
        if productsCoreData.isEmpty {
            await fetchProducts()
        }
    }
    private func onSearchTextChanged() {
        searchTask?.cancel()
        searchTask = Task {
            await releaseResources()
            do {
                try await Task.sleep(for: .seconds(0.3))
                try Task.checkCancellation()
            } catch {
                return
            }
            await fetchProducts()
        }
    }
}
