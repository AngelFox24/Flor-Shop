import SwiftUI
import Equatable

@Equatable
struct SaleProductView: View {
    @Environment(SyncWebSocketClient.self) private var syncManager
    @State var productViewModel: ProductViewModel
    @EquatableIgnoredUnsafeClosure
    let showMenu: () -> Void
    init(ses: SessionContainer, showMenu: @escaping () -> Void) {
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
                ProductTopToolbar(productViewModel: $productViewModel, badge: nil)
                MainBottomToolbar(destination: .addProduct)
            }
            .onChange(of: syncManager.lastTokenByEntities.product) { _, newValue in
                Task {
                    await productViewModel.updateCurrentList(newToken: newValue)
                }
            }
            .onChange(of: syncManager.lastTokenByEntities.productSubsidiary) { _, newValue in
                Task {
                    await productViewModel.updateCurrentList(newToken: newValue)
                }
            }
            .task {
                await productViewModel.lazyFetchProducts()
            }
    }
}
#Preview {
    @Previewable @State var overlay = OverlayViewModel()
    @Previewable @State var webSocket: SyncWebSocketClient = SyncWebSocketClient(
        synchronizerDBUseCase: SynchronizerDBInteractorMock(),
        lastTokenByEntities: LastTokenByEntities(
            company: 1,
            subsidiary: 1,
            customer: 1,
            employee: 1,
            product: 1,
            sale: 1,
            productSubsidiary: 1,
            employeeSubsidiary: 1
        )
    )
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    let session = SessionContainer.preview
    SaleProductView(ses: SessionContainer.preview, showMenu: {})
        .environment(mainRouter)
        .environment(session)
        .environment(webSocket)
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
                    ForEach(0 ..< viewModel.deleteCount, id: \.self) { _ in
                        Spacer()
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .onAppear {
                                print("Products gosht")
                                loadProducts()
                            }
                    }
                    ForEach(viewModel.productsCoreData) { producto in
                        CardViewTipe2(
                            imageUrl: producto.imageUrl,
                            topStatusColor: Color.red,
                            topStatus: nil,
                            mainText: producto.name,
                            mainIndicatorPrefix: "S/. ",
                            mainIndicator: producto.unitPrice.solesString,
                            mainIndicatorAlert: false,
                            secondaryIndicatorSuffix: " u",
                            secondaryIndicator: String(producto.qty),
                            secondaryIndicatorAlert: false, size: 80
                        )
                        .padding(.horizontal, 10)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        .listRowBackground(Color.background)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                agregarProductoACarrito(producto: producto)
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
                        .onAppear(perform: {
                            shouldLoadData(product: producto)
                        })
                    }
                }
                .scrollIndicators(ScrollIndicatorVisibility.hidden)
                .listStyle(PlainListStyle())
            }
        }
    }
    func shouldLoadData(product: Product) {
        Task {
//            loading = true
            await viewModel.shouldLoadData(product: product)
//            loading = false
        }
    }
    func loadProducts() {
        Task {
//            loading = true
            await viewModel.releaseResources()
            await viewModel.lazyFetchProducts()
//            loading = false
        }
    }
    func agregarProductoACarrito(producto: Product) {
        let loadingId = self.overlayViewModel.showLoading()
        Task {
            do {
                try await viewModel.addProductoToCarrito(product: producto)
                self.overlayViewModel.endLoading(id: loadingId)
            } catch {
                print("[SaleListProductView] Ha ocurrido un error: \(error)")
                self.overlayViewModel.showAlert(
                    title: "Error",
                    message: "Ha ocurrido un error al agregar producto al carrito.",
                    primary: AlertAction(
                        title: "Aceptar",
                        action: {
                            self.overlayViewModel.endLoading(id: loadingId)
                        }
                    )
                )
            }
        }
    }
}
