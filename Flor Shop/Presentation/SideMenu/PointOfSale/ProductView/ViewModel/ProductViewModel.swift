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
    
    let getProductsUseCase: GetProductsUseCase
    
    init(getProductsUseCase: GetProductsUseCase) {
        self.getProductsUseCase = getProductsUseCase
        addSearchTextSuscriber()
    }
    func fetchProducts(page: Int = 1, nextPage: Bool = true) {
        let productsNewCarge = self.getProductsUseCase.execute(seachText: searchText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page)
        lastCarge = productsNewCarge.count
        if lastCarge > 0 {
            if nextPage {
                self.currentPagesInScreen.append([page, lastCarge])
                self.productsCoreData.append(contentsOf: productsNewCarge)
            } else {
                self.currentPagesInScreen.insert(contentsOf: [[page, lastCarge]], at: 0)
                self.productsCoreData.insert(contentsOf: productsNewCarge, at: 0)
            }
        }
    }
    func fetchNextPage() {
        guard let firstCharge = self.currentPagesInScreen.first?[1] else { return }
        guard let lastPage = self.currentPagesInScreen.last?[0] else { return }
        fetchProducts(page: lastPage + 1)
        print("fetchNextPage: \(lastPage + 1)")
        if lastCarge > 0 {
            if self.currentPagesInScreen.count > self.maxPagesToLoad {
                self.deleteCount = self.deleteCount + firstCharge
                self.productsCoreData.removeFirst(firstCharge)
                self.currentPagesInScreen.removeFirst()
            }
        }
        print("CurrentPagesInScreen: \(currentPagesInScreen.description)")
        print("CurrentPagesInScreenCount: \(currentPagesInScreen.count.description)")
        print("ProductsCoreData: \(productsCoreData.count.description)")
    }
    func fetchPreviousPage() {
        guard let firstCharge = self.currentPagesInScreen.first?[1] else { return }
        guard let firstPage = self.currentPagesInScreen.first?[0] else { return }
        guard let lastCharge = self.currentPagesInScreen.last?[1] else { return }
        let previousPage = firstPage - 1
        print("fetchPreviousPage: \(previousPage)")
        if previousPage >= 1 {
            fetchProducts(page: previousPage, nextPage: false)
            if lastCarge > 0 {
                if self.currentPagesInScreen.count > self.maxPagesToLoad {
                    print("Se borrara espacios: \(self.deleteCount - firstCharge)")
                    self.deleteCount = self.deleteCount - firstCharge
                    self.productsCoreData.removeLast(lastCharge)
                    self.currentPagesInScreen.removeLast()
                } else {
                    self.deleteCount = 0
                }
            }
        }
        print("CurrentPagesInScreen: \(currentPagesInScreen.description)")
        print("CurrentPagesInScreenCount: \(currentPagesInScreen.count.description)")
        print("ProductsCoreData: \(productsCoreData.count.description)")
    }
    func addSearchTextSuscriber() {
        $searchText
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                //self.currentPage = 1
                fetchProducts()
            })
            .store(in: &cancellableSet)
    }
    func shouldLoadData(product: Product) {
        if self.productsCoreData.isEmpty {
            return
        } else {
            guard let lastProduct = self.productsCoreData.last else { return }
            guard let firstProduct = self.productsCoreData.first else { return }
            if product == lastProduct {
                print("fetchNextPage")
                fetchNextPage()
            } else if product == firstProduct {
                fetchPreviousPage()
            }
        }
    }
    
    func lazyFetchProducts() {
        if productsCoreData.isEmpty {
            fetchProducts()
        }
    }
}
