//
//  ProductCoreDataViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 1/05/23.
//

import Foundation
import Combine

class ProductViewModel: ObservableObject {
    @Published var productsCoreData: [Product] = []
    @Published var searchText: String = ""
    @Published var primaryOrder: PrimaryOrder = .nameAsc
    @Published var filterAttribute: ProductsFilterAttributes = .allProducts
    @Published var deleteCount: Int = 0
    
    private var currentPagesInScreen: [[Int]] = []
    private let maxPagesToLoad: Int = 3
    private var lastCarge: Int = 0
    private var cancellableSet = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>? = nil
    
    let synchronizerDBUseCase: SynchronizerDBUseCase
    let getProductsUseCase: GetProductsUseCase
    
    init(
        synchronizerDBUseCase: SynchronizerDBUseCase,
        getProductsUseCase: GetProductsUseCase
    ) {
        self.synchronizerDBUseCase = synchronizerDBUseCase
        self.getProductsUseCase = getProductsUseCase
        addSearchTextSuscriber()
    }
    func sync() async throws {
        try await self.synchronizerDBUseCase.sync()
    }
    func addSearchTextSuscriber() {
        $searchText
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.searchTask?.cancel()
                self.searchTask = Task {
                    await self.releaseResources()
                    await self.fetchProducts()
                }
            })
            .store(in: &cancellableSet)
    }
    func fetchProducts(page: Int = 1, nextPage: Bool = true) async {
        let pages = currentPagesInScreen.map { $0[0] }
        if !pages.contains(page) {
            let productsNewCarge = self.getProductsUseCase.execute(seachText: searchText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page)
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
                self.deleteCount = self.deleteCount + firstCharge
                await MainActor.run {
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
    func shouldLoadData(product: Product) async {
        if self.productsCoreData.isEmpty {
            return
        } else {
            guard let lastProduct = self.productsCoreData.last else { return }
            guard let firstProduct = self.productsCoreData.first else { return }
            if product == lastProduct {
                await fetchNextPage()
            } else if product == firstProduct {
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
        print("Empezo a fetch lazy")
        if productsCoreData.isEmpty {
            await fetchProducts()
        }
        print("Termino a fetch lazy")
    }
}
