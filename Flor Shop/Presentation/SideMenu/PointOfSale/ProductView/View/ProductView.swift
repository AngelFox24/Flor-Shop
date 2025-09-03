import SwiftUI
import AVFoundation

struct ProductView: View {
    @Environment(SyncWebSocketClient.self) private var syncManager
    @Binding var productViewModel: ProductViewModel
    @Binding var showMenu: Bool
    var body: some View {
        ZStack {
            ListaControler(viewModel: $productViewModel)
            VStack {
                ProductSearchTopBar(showMenu: $showMenu, productViewModel: $productViewModel)
                Spacer()
                CustomTabView()
            }
        }
        .onAppear {
            Task {
                await productViewModel.lazyFetchProducts()
            }
        }
        .onChange(of: syncManager.lastTokenByEntities.product) { _, newValue in
            Task {
                await productViewModel.updateCurrentList(newToken: newValue)
            }
        }
    }
}

#Preview {
    @Previewable @State var router = FlorShopRouter.previewRouter()
    @Previewable @State var vm = ProductViewModelFactory.getProductViewModel(sessionContainer: SessionContainer.preview)
    ProductView(productViewModel: $vm, showMenu: .constant(false))
        .environment(router)
}

struct ListaControler: View {
    @Binding var viewModel: ProductViewModel
    @State private var audioPlayer: AVAudioPlayer?
    var body: some View {
        HStack(spacing: 0) {
            if viewModel.productsCoreData.count == 0 {
                VStack {
                    Image("groundhog_finding")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 300)
                    Text("Agreguemos productos a nuestra tienda.")
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .font(.custom("Artifika-Regular", size: 18))
//                    Button(action: goToEditProduct) {
//                        CustomButton1(text: "Agregar")
//                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("color_background"))
            } else {
                HStack(spacing: 0, content: {
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
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            .listRowBackground(Color("color_background"))
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button(action: {
                                    agregarProductoACarrito(producto: producto)
                                }, label: {
                                    Image(systemName: "cart")
                                })
                                .tint(Color("color_accent"))
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(action: {
//                                    editProduct(product: producto)
                                }, label: {
                                    Image(systemName: "pencil")
                                })
                                .tint(Color("color_accent"))
                            }
                        }
                    }
                    .scrollIndicators(ScrollIndicatorVisibility.hidden)
                    .listStyle(PlainListStyle())
                })
            }
        }
        .background(Color("color_background"))
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

