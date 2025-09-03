import SwiftUI

struct PointOfSaleView: View {
    @State var productViewModel: ProductViewModel
    @Binding var showMenu: Bool
    init(ses: SessionContainer, showMenu: Binding<Bool>) {
        self.productViewModel = ProductViewModelFactory.getProductViewModel(sessionContainer: ses)
        self._showMenu = showMenu
    }
    var body: some View {
        ZStack {
            if showMenu {
                VStack(spacing: 0, content: {
                    Color.primary
                    Color.background
                })
                .ignoresSafeArea()
            }
            VStack(spacing: 0) {
                ProductView(productViewModel: $productViewModel, showMenu: $showMenu)
            }
            .cornerRadius(showMenu ? 35 : 0)
            .padding(.top, showMenu ? 0 : 1)
        }
    }
}
#Preview {
    PointOfSaleView(ses: SessionContainer.preview, showMenu: .constant(false))
}
