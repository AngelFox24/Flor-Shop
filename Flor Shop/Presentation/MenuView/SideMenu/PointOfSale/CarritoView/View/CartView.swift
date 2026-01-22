import SwiftUI

struct CartView: View {
    @Environment(FlorShopRouter.self) private var router
    @State var cartViewModel: CartViewModel
    @State private var datesito = Date()
    init(ses: SessionContainer) {
        cartViewModel = CartViewModelFactory.getCartViewModel(sessionContainer: ses)
    }
    var body: some View {
        ListCartController(cartViewModel: $cartViewModel, backAction: router.back)
            .navigationTitle("Carrito")
            .navigationSubtitle(Text(datesito.formatted(.dateTime.day().month().year())))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CartTopToolbar(cartViewModel: $cartViewModel)
            }
            .task {
                await cartViewModel.fetchCart()
            }
    }
}

#Preview {
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    CartView(ses: SessionContainer.preview)
        .environment(mainRouter)
}

struct ListCartController: View {
    @Binding var cartViewModel: CartViewModel
    let backAction: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            if let cart = cartViewModel.cartCoreData {
                List {
                    ForEach(cart.cartDetails) { cartDetail in
                        CardViewTipe3(
                            cartDetail: cartDetail,
                            size: 80,
                            decreceProductAmount: decreceProductAmount,
                            increaceProductAmount: increaceProductAmount
                        )
                        .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        .listRowBackground(Color.background)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive, action: {
                                deleteCartDetail(cartDetailId: cartDetail.id)
                            }, label: {
                                Image(systemName: "trash")
                            })
                            .tint(Color.accentColor)
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                .scrollIndicators(ScrollIndicatorVisibility.hidden)
                .listStyle(PlainListStyle())
                .safeAreaBar(edge: .top, alignment: .center) {
                    let total = cartViewModel.cartCoreData?.total.solesString ?? "0"
                    TotalSafeAreaBarView(total: total)
                }
            } else {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Image("groundhog-money")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300)
                        Text("Deslizemos productos al carrito de ventas.")
                            .font(.custom("Artifika-Regular", size: 18))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                        Button(action: backAction) {
                            CustomButton1(text: "Ir a Productos")
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 10)
        .background(Color.background)
    }
//    func goToProductsList() {
//        self.tab = .magnifyingglass
//        addProductToCart()
//    }
//    func addProductToCart() {
//        let car = Car(
//            id: UUID(),
//            cartDetails: [.init(
//                id: UUID(),
//                quantity: 3,
//                product: .init(
//                    id: UUID(),
//                    productCic: UUID().uuidString,
//                    active: true,
//                    name: "Test PRoduct",
//                    qty: 23,
//                    unitType: .unit,
//                    unitCost: .init(3450),
//                    unitPrice: .init(5650)
//                )
//            )]
//        )
//        cartViewModel.cartCoreData = car
//    }
    func deleteCartDetail(cartDetailId: UUID) {
        Task {
//            loading = true
            do {
                try await cartViewModel.deleteCartDetail(cartDetailId: cartDetailId)
                await cartViewModel.fetchCart()
            } catch {
//                router.presentAlert(.error(error.localizedDescription))
            }
//            loading = false
        }
    }
    func decreceProductAmount(cartDetail: CartDetail) {
        Task {
//            loading = true
            do {
                if cartDetail.quantity - 1 <= 0 {
                    try await cartViewModel.deleteCartDetail(cartDetailId: cartDetail.id)
                } else if let productCic = cartDetail.product.productCic {
                    try await cartViewModel.changeProductAmount(cartDetailId: cartDetail.id, productCic: productCic, amount: cartDetail.quantity - 1)
                }
                await cartViewModel.fetchCart()
            } catch {
//                router.presentAlert(.error(error.localizedDescription))
            }
//            loading = false
        }
    }
    func increaceProductAmount(cartDetail: CartDetail) {
        Task {
//            loading = true
            do {
                if let productCic = cartDetail.product.productCic {
                    try await cartViewModel.changeProductAmount(cartDetailId: cartDetail.id, productCic: productCic, amount: cartDetail.quantity + 1)
                    await cartViewModel.fetchCart()
                }
            } catch {
//                router.presentAlert(.error(error.localizedDescription))
            }
//            loading = false
        }
    }
}
