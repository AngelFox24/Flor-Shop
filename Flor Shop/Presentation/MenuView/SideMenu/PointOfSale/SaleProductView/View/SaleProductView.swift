import SwiftUI
import Equatable

@Equatable
struct SaleProductView: View {
    @Environment(OverlayViewModel.self) private var overlayViewModel
    @Environment(SessionContainer.self) var sessionContainer
    @Environment(FlorShopRouter.self) var florShopRouter
    @State var productViewModel: ProductViewModel
    @EquatableIgnoredUnsafeClosure
    let showMenu: () -> Void
    init(ses: SessionContainer, showMenu: @escaping () -> Void) {
        print("[SaleProductView] Init.")
        self.productViewModel = ProductViewModelFactory.getProductViewModel(sessionContainer: ses)
        self.showMenu = showMenu
    }
    var body: some View {
        SaleListProductView(viewModel: productViewModel)
            .navigationTitle("Productos")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $productViewModel.searchText, placement: .toolbar)
            .searchToolbarBehavior(.minimize)
            .toolbar {
                LogoToolBar(action: showMenu)
                ProductTopToolbar(productViewModel: $productViewModel)
                MainBottomToolbar(destination: .addProduct)
            }
            .task {
                await initialConfig()
            }
            .task(id: productViewModel.taskID) {
                await watchProducts()
            }
    }
    private func initialConfig() async {
        let loadingId = self.overlayViewModel.showLoading(origin: "[MenuView]")
        do {
            if try await !self.sessionContainer.employeeRepository.isEmployeeProfileComplete() {
                self.florShopRouter.present(fullScreen: .completeEmployeeProfile)
            }
            self.overlayViewModel.endLoading(id: loadingId, origin: "[MenuView]")
        } catch {
            self.overlayViewModel.showAlert(
                title: "Error en la inicializacion.",
                message: "Ha ocurrido un error en la incializacion del perfil.",
                primary: ConfirmAction(title: "Aceptar") {
                    self.overlayViewModel.endLoading(id: loadingId, origin: "[MenuView]")
                }
            )
        }
    }
    private func watchProducts() async {
        do {
            try await self.productViewModel.watchProducts()
        } catch {
            self.overlayViewModel.showAlert(
                title: "Error",
                message: "Ha ocurrido un error al cargar los productos.",
                primary: ConfirmAction(
                    title: "Aceptar",
                    action: {}
                )
            )
        }
    }
}
#Preview {
    @Previewable @State var overlay = OverlayViewModel()
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    let session = SessionContainer.preview
    SaleProductView(ses: SessionContainer.preview, showMenu: {})
        .environment(mainRouter)
        .environment(session)
        .environment(overlay)
}

struct SaleListProductView: View {
    @Environment(OverlayViewModel.self) private var overlayViewModel
    var viewModel: ProductViewModel
    var body: some View {
        HStack(spacing: 0) {
            if viewModel.productsCoreData.count == 0 {
                EmptyView(
                    imageName: "groundhog_finding",
                    text: "Agreguemos productos a nuestra tienda.",
                    textButton: "Agregar",
                    pushDestination: .addProduct
                )
            } else {
                List {
                    ForEach(viewModel.productsCoreData) { producto in
                        ProductCardView(
                            imageUrl: producto.imageUrl,
                            mainText: producto.name,
                            mainIndicatorPrefix: "S/. ",
                            mainIndicator: producto.unitPrice.solesString,
                            secondaryIndicatorSuffix: " \(producto.unitType.shortDescription)",
                            secondaryIndicator: producto.quantityDisplay
                        )
                        .padding(.horizontal, 10)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        .listRowBackground(Color.background)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                guard let productCic = producto.productCic else { return }
                                agregarProductoACarrito(productCic: productCic)
                            } label: {
                                Image(systemName: "cart")
                            }
                            .tint(Color.accentColor)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if let productCic = producto.productCic {
                                NavigationButton(push: .editProduct(productCic: productCic)) {
                                    Image(systemName: "pencil")
                                }
                                .tint(Color.accentColor)
                            } else {
                                Image(systemName: "pencil")
                                    .tint(Color.gray)
                            }
                        }
                    }
                }
                .scrollIndicators(ScrollIndicatorVisibility.hidden)
                .listStyle(PlainListStyle())
            }
        }
    }
    func agregarProductoACarrito(productCic: String) {
        let loadingId = self.overlayViewModel.showLoading(origin: "[SaleListProductView]")
        Task {
            do {
                try await viewModel.addProductoToCarrito(productCic: productCic)
                await viewModel.updateCartQuantity()
                self.overlayViewModel.endLoading(id: loadingId, origin: "[SaleListProductView]")
            } catch {
                print("[SaleListProductView] Ha ocurrido un error: \(error)")
                self.overlayViewModel.showAlert(
                    title: "Error",
                    message: "Ha ocurrido un error al agregar producto al carrito.",
                    primary: ConfirmAction(
                        title: "Aceptar",
                        action: {
                            self.overlayViewModel.endLoading(id: loadingId, origin: "[SaleListProductView]")
                        }
                    )
                )
            }
        }
    }
}
