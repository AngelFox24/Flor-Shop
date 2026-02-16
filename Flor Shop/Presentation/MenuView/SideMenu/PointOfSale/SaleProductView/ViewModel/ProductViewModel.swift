import Foundation
import SwiftUI

@Observable
final class ProductViewModel {
    var productsCoreData: [Product] = []
    var searchText: String = ""
    var primaryOrder: PrimaryOrder = .nameAsc
    var filterAttribute: ProductsFilterAttributes = .allProducts
    var cartCount: Int = 0
    //Task management
    var taskID: String { "\(self.searchText)-\(self.primaryOrder)-\(self.filterAttribute)" }
    
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
    func addProductoToCarrito(productCic: String) async throws {
        try await self.addProductoToCartUseCase.execute(productCic: productCic)
    }
    func watchProducts() async throws {
        for try await products in try self.getProductsUseCase
            .watchProducts(seachText: searchText, primaryOrder: primaryOrder, filterAttribute: filterAttribute) {
            try Task.checkCancellation()
            await MainActor.run {
                withAnimation {
                    self.productsCoreData = products
                }
            }
        }
    }
}
