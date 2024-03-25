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
    @Published var scrollToIndex: Int = 0
    @Published var currentIndex: Int = 1
    
    // TODO: Optimizar Lista
    private var currentPagesInScreen: [[Int]] = []
    //-------------------------
    //private var currentPage: Int = 1
    private var lastCarge: Int = 0
    private var cancellableSet = Set<AnyCancellable>()
    
    let getProductsUseCase: GetProductsUseCase
    
    init(getProductsUseCase: GetProductsUseCase) {
        self.getProductsUseCase = getProductsUseCase
        addSearchTextSuscriber()
    }
    func fetchProducts(page: Int = 1) {
        if page == 1 {
            self.currentPagesInScreen = []
            let productsNewCarge = self.getProductsUseCase.execute(seachText: searchText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page)
            lastCarge = productsNewCarge.count
            
            
            self.productsCoreData = productsNewCarge
            self.currentPagesInScreen.append([page,lastCarge])
        } else {
            if lastCarge > 0 {
                let productsNewCarge = self.getProductsUseCase.execute(seachText: searchText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page)
                lastCarge = productsNewCarge.count
                guard let lastPage = self.currentPagesInScreen.last?[0] else { return }
                guard let firstPage = self.currentPagesInScreen.first?[0] else { return }
                if lastPage + 1 == page {
                    self.currentPagesInScreen.append([page, lastCarge])
                    self.productsCoreData.append(contentsOf: productsNewCarge)
                } else if firstPage - 1 == page {
                    self.currentPagesInScreen.insert(contentsOf: [[page, lastCarge]], at: 0)
                    self.productsCoreData.insert(contentsOf: productsNewCarge, at: 0)
                }
            }
        }
    }
    func fetchNextPageBK() {
        //currentPage = currentPage + 1
        //fetchProducts(page: currentPage)
    }
    func removeUnnecesaryItems() {
        //let toRemove = self.productsCoreData.count - 60
        //if toRemove > 0 {
        self.productsCoreData.removeFirst()
        self.scrollToIndex = self.currentIndex - 2
    }
    func fetchNextPage() {
        guard let firstCharge = self.currentPagesInScreen.first?[1] else { return }
        guard let lastPage = self.currentPagesInScreen.last?[0] else { return }
        fetchProducts(page: lastPage + 1)
        print("fetchNextPage: \(lastPage + 1)")
        //self.currentPagesInScreen.append(lastPage + 1)
        if self.currentPagesInScreen.count > 4 {
            self.productsCoreData.removeFirst(firstCharge)
            self.currentPagesInScreen.removeFirst()
            if self.currentIndex - 2 - firstCharge > 0 {
                self.scrollToIndex = self.currentIndex - 2 - firstCharge
            }
        }
        print("CurrentPagesInScreen: \(currentPagesInScreen.description)")
        print("CurrentPagesInScreenCount: \(currentPagesInScreen.count.description)")
        print("ProductsCoreData: \(productsCoreData.count.description)")
    }
    func fetchPreviousPage() {
        guard let firstPage = self.currentPagesInScreen.first?[0] else { return }
        guard let lastCharge = self.currentPagesInScreen.last?[1] else { return }
        let previousPage = firstPage - 1
        print("fetchPreviousPage: \(previousPage)")
        if previousPage >= 1 {
            fetchProducts(page: previousPage)
            //self.currentPagesInScreen.insert(contentsOf: [previousPage], at: 0)
            if self.currentPagesInScreen.count > 4 {
                self.productsCoreData.removeLast(lastCharge)
                self.currentPagesInScreen.removeLast()
                if self.currentIndex + 2 + firstPage <= self.productsCoreData.count {
                    self.scrollToIndex = self.currentIndex + 2
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
