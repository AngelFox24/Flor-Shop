import SwiftUI

struct ProductSearchTopBar: View {
    @Binding var showMenu: Bool
    @Binding var productViewModel: ProductViewModel
    var body: some View {
        HStack {
            FlorShopButton {
                showMenu.toggle()
            }
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
        .padding(.horizontal, 10)
        .padding(.top, showMenu ? 15 : 0)
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
    ProductSearchTopBar(showMenu: .constant(false), productViewModel: $vm)
        .background(Color.primary)
}
