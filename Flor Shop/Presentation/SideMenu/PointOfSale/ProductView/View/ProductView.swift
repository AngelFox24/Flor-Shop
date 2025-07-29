import SwiftUI
import CoreData
import AVFoundation
import StoreKit

struct CustomProductView: View {
    @EnvironmentObject var productViewModel: ProductViewModel
    @Environment(SyncWebSocketClient.self) private var syncManager
    @Binding var tab: Tab
    var body: some View {
        VStack(spacing: 0) {
            ProductSearchTopBar()
            ListaControler(tab: $tab)
        }
        .onAppear {
            Task {
                await productViewModel.lazyFetchProducts()
            }
        }
        .onChange(of: syncManager.lastTokenByEntities.product) { oldValue, newValue in
            print("Se encontro nuevo token en Producto, Old: \(oldValue), New: \(newValue)")
            Task {
                await productViewModel.updateCurrentList(newToken: newValue)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        CustomProductView(tab: .constant(.magnifyingglass))
            .environmentObject(dependencies.productsViewModel)
            .environmentObject(dependencies.cartViewModel)
    }
}

struct ListaControler: View {
    @Environment(Router.self) private var router
    @EnvironmentObject var agregarViewModel: AgregarViewModel
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    @EnvironmentObject var carritoCoreDataViewModel: CartViewModel
    @AppStorage("isRequested20AppRatingReview") var isRequested20AppRatingReview: Bool = true
    @Environment(\.requestReview) var requestReview
    @Binding var tab: Tab
    @State private var audioPlayer: AVAudioPlayer?
    var body: some View {
        HStack(spacing: 0) {
            if productsCoreDataViewModel.productsCoreData.count == 0 {
                VStack {
                    Image("groundhog_finding")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 300)
                    Text("Agreguemos productos a nuestra tienda.")
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .font(.custom("Artifika-Regular", size: 18))
                    Button(action: goToEditProduct) {
                        CustomButton1(text: "Agregar")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("color_background"))
            } else {
                SideSwipeView(swipeDirection: .right, swipeAction: goToEditProduct)
                HStack(spacing: 0, content: {
                    List {
                        ForEach(0 ..< productsCoreDataViewModel.deleteCount, id: \.self) { _ in
                            Spacer()
                                .frame(maxWidth: .infinity, minHeight: 80)
                                .onAppear {
                                    print("Products gosht")
                                    loadProducts()
                                }
                        }
                        ForEach(productsCoreDataViewModel.productsCoreData) { producto in
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
                                    editProduct(product: producto)
                                }, label: {
                                    Image(systemName: "pencil")
                                })
                                .tint(Color("color_accent"))
                            }
                            .onAppear(perform: {
                                shouldLoadData(product: producto)
                                if productsCoreDataViewModel.productsCoreData.count >= 20 && isRequested20AppRatingReview {
                                    requestReview()
                                    isRequested20AppRatingReview = false
                                }
                            })
                        }
                    }
                    .scrollIndicators(ScrollIndicatorVisibility.hidden)
//                    .padding(.horizontal, 10)
                    .listStyle(PlainListStyle())
                })
                SideSwipeView(swipeDirection: .left, swipeAction: goToCart)
            }
        }
        .background(Color("color_background"))
    }
    func goToEditProduct() {
        self.tab = .plus
    }
    func goToCart() {
        self.tab = .cart
    }
    func shouldLoadData(product: Product) {
        Task {
//            loading = true
            await productsCoreDataViewModel.shouldLoadData(product: product)
//            loading = false
        }
    }
    func loadProducts() {
        Task {
//            loading = true
            await productsCoreDataViewModel.releaseResources()
            await productsCoreDataViewModel.lazyFetchProducts()
//            loading = false
        }
    }
    func editProduct(product: Product) {
        Task {
//            loading = true
            do {
                try await agregarViewModel.editProduct(product: product)
//                playSound(named: "Success1")
                self.tab = .plus
            } catch {
                router.presentAlert(.error(error.localizedDescription))
                playSound(named: "Fail1")
            }
//            loading = false
        }
    }
    func agregarProductoACarrito(producto: Product) {
        Task {
//            loading = true
            do {
                try await carritoCoreDataViewModel.addProductoToCarrito(product: producto)
                await carritoCoreDataViewModel.fetchCart()
                playSound(named: "Success1")
            } catch {
                router.presentAlert(.error(error.localizedDescription))
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
