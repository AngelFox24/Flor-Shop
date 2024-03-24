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
    
    // TODO: Optimizar Lista
    //-------------------------
    private var currentPage: Int = 1
    private var lastCarge: Int = 0
    private var cancellableSet = Set<AnyCancellable>()
    
    let getProductsUseCase: GetProductsUseCase
    
    init(getProductsUseCase: GetProductsUseCase) {
        self.getProductsUseCase = getProductsUseCase
        addSearchTextSuscriber()
    }
    func fetchProducts(page: Int = 1) {
        if page == 1 {
            let productsNewCarge = self.getProductsUseCase.execute(seachText: searchText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page)
            lastCarge = productsNewCarge.count
            self.productsCoreData = productsNewCarge
        } else {
            if lastCarge > 0 {
                let productsNewCarge = self.getProductsUseCase.execute(seachText: searchText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page)
                lastCarge = productsNewCarge.count
                self.productsCoreData.append(contentsOf: productsNewCarge)
            }
        }
        //productsCoreData = self.getProductsUseCase.execute(seachText: searchText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: currentPage)
    }
    func fetchNextPage() {
        currentPage = currentPage + 1
        fetchProducts(page: currentPage)
    }
    func addSearchTextSuscriber() {
        $searchText
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.currentPage = 1
                fetchProducts()
            })
            .store(in: &cancellableSet)
    }
    func shouldLoadData(product: Product) -> Bool {
        if self.productsCoreData.isEmpty {
            return false
        } else {
            guard let lastProduct = self.productsCoreData.last else { return false }
            return product == lastProduct
        }
    }
    
    func lazyFetchProducts() {
        if productsCoreData.isEmpty {
            fetchProducts()
        }
    }
}
