import SwiftUI
import AVFoundation

struct SaleProductView: View {
    @Environment(SyncWebSocketClient.self) private var syncManager
    @State var productViewModel: ProductViewModel
    let showMenu: () -> Void
    init(ses: SessionContainer, showMenu: @escaping () -> Void) {
        self.productViewModel = ProductViewModelFactory.getProductViewModel(sessionContainer: ses)
        self.showMenu = showMenu
    }
    var body: some View {
        ZStack {
            ListaControler(viewModel: $productViewModel)
            VStack {
                ProductSearchTopBar(productViewModel: $productViewModel, showMenu: showMenu)
                Spacer()
                BottomBar(findText: $productViewModel.searchText, addDestination: .addProduct)
            }
            .padding(.horizontal, 10)
        }
        .background(Color.background)
        .onChange(of: syncManager.lastTokenByEntities.product) { _, newValue in
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
    @Previewable @State var webSocket: SyncWebSocketClient = SyncWebSocketClient(
        synchronizerDBUseCase: SynchronizerDBInteractorMock(),
        lastTokenByEntities: LastTokenByEntities(
            image: 1,
            company: 1,
            subsidiary: 1,
            customer: 1,
            employee: 1,
            product: 1,
            sale: 1
        )
    )
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    let session = SessionContainer.preview
    SaleProductView(ses: SessionContainer.preview, showMenu: {})
        .environment(mainRouter)
        .environment(session)
        .environment(webSocket)
}

struct ListaControler: View {
    @Binding var viewModel: ProductViewModel
    @State private var audioPlayer: AVAudioPlayer?
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
                HStack(spacing: 0) {
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
                                imageUrl: producto.image,
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
                                .tint(Color.accent)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                NavigationButton(push: .editProduct(productId: producto.id)) {
                                    Image(systemName: "pencil")
                                }
                                .tint(Color.accent)
                            }
                        }
                    }
                    .safeAreaInset(edge: .top) {
                        Color.clear.frame(height: 32) // margen superior
                    }
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 32) // margen inferior
                    }
                    .scrollIndicators(ScrollIndicatorVisibility.hidden)
                    .listStyle(PlainListStyle())
                }
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
        Task {
//            loading = true
            do {
                try await viewModel.addProductoToCarrito(product: producto)
                playSound(named: "Success1")
            } catch {
//                router.presentAlert(.error(error.localizedDescription))
                playSound(named: "Fail1")
            }
//            loading = false
        }
    }
    private func playSound(named fileName: String) {
        var soundURL: URL?
        soundURL = Bundle.main.url(forResource: fileName, withExtension: "mp3")
        guard let url = soundURL else {
            print("No se pudo encontrar el archivo de sonido.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("No se pudo reproducir el sonido. Error: \(error.localizedDescription)")
        }
    }
}
