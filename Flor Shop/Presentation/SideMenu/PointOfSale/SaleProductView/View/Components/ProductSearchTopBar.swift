import SwiftUI

struct ProductSearchTopBar: View {
    @Binding var productViewModel: ProductViewModel
    let showMenu: () -> Void
    var body: some View {
        HStack {
            FlorShopButton(backAction: showMenu)
            Spacer()
            HStack(spacing: 2) {
                NavigationButton(push: .cartList) {
                    Image(systemName: "cart")
                        .modifier(FlorShopButtonStyleLigth())
                }
                FilterButtonView(productViewModel: $productViewModel)
            }
            .padding(.horizontal, 8)
            .background(Color.white)
            .clipShape(.capsule)
            .onChange(of: productViewModel.primaryOrder) { _, _ in
                loadProducts()
            }
            .onChange(of: productViewModel.filterAttribute) { _, _ in
                loadProducts()
            }
        }
    }
    func loadProducts() {
        Task {
//            router.isLoading = true
            await productViewModel.releaseResources()
            await productViewModel.fetchProducts()
//            router.isLoading = false
        }
    }
}

#Preview {
    @Previewable @State var vm = ProductViewModelFactory.getProductViewModel(sessionContainer: SessionContainer.preview)
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    ProductSearchTopBar(productViewModel: $vm, showMenu: {})
        .background(Color.primary)
        .environment(mainRouter)
}
