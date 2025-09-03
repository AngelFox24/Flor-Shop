import SwiftUI

struct EditProductView: View {
    @Environment(FlorShopRouter.self) private var router
    @State var agregarViewModel: AgregarViewModel
    let productId: UUID
    init(
        ses: SessionContainer,
        productId: UUID
    ) {
        self.agregarViewModel = AgregarViewModelFactory.getProductViewModel(sessionContainer: ses)
        self.productId = productId
    }
    var body: some View {
        VStack(spacing: 0) {
            AgregarTopBar(backAction: router.back) {
                saveProduct()
            }
            CamposProductoAgregar(agregarViewModel: $agregarViewModel)
        }
        .task {
            try? await agregarViewModel.loadProduct(productId: productId)
        }
    }
    private func saveProduct() {
        Task {
            do {
                try await agregarViewModel.addProduct()
//                await productViewModel.releaseResources()
//                playSound(named: "Success1")
            } catch {
//                router.presentAlert(.error(error.localizedDescription))
//                playSound(named: "Fail1")
            }
        }
    }
}

#Preview {
    EditProductView(ses: SessionContainer.preview, productId: UUID())
}
