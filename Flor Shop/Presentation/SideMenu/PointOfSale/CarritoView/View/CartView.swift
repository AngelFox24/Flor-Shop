import SwiftUI

struct CartView: View {
    @Environment(CartViewModel.self) var cartViewModel
    @Binding var tab: Tab
    var body: some View {
        VStack(spacing: 0) {
            CartTopBar()
            ListCartController(tab: $tab)
        }
//        .onAppear {
//            Task {
//                loading = true
//                await cartViewModel.lazyFetchCart()
//                loading = false
//            }
//        }
    }
}

#Preview {
    @Previewable @State var tab: Tab = .magnifyingglass
    let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
    let dependencies = BusinessDependencies(sessionConfig: ses)
    CartView(tab: $tab)
        .environment(dependencies.cartViewModel)
}

struct ListCartController: View {
    @Environment(Router.self) private var router
    @Environment(CartViewModel.self) var cartViewModel
    @Binding var tab: Tab
    var body: some View {
        VStack(spacing: 0) {
            if let cart = cartViewModel.cartCoreData {
                HStack(spacing: 0) {
                    SideSwipeView(swipeDirection: .right, swipeAction: goToProductsList)
                    List {
                        ForEach(cart.cartDetails) { cartDetail in
                            CardViewTipe3(
                                cartDetail: cartDetail,
                                size: 80,
                                decreceProductAmount: decreceProductAmount,
                                increaceProductAmount: increaceProductAmount
                            )
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            .listRowBackground(Color("color_background"))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive, action: {
                                    deleteCartDetail(cartDetail: cartDetail)
                                }, label: {
                                    Image(systemName: "trash")
                                })
                                .tint(Color("color_accent"))
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                    .scrollIndicators(ScrollIndicatorVisibility.hidden)
                    .listStyle(PlainListStyle())
                    SideSwipeView(swipeDirection: .left, swipeAction: goToPay)
                }
            } else {
                VStack {
                    Image("groundhog-money")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 300)
                    Text("Deslizemos productos al carrito de ventas.")
                        .font(.custom("Artifika-Regular", size: 18))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                    Button(action: {
                        goToProductsList()
                    }, label: {
                        CustomButton1(text: "Ir a Productos")
                    })
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color("color_background"))
    }
    func goToProductsList() {
//        self.tab = .magnifyingglass
        addProductToCart()
    }
    func goToPay() {
        router.presentSheet(.payment)
    }
    func addProductToCart() {
        let car = Car(
            id: UUID(),
            cartDetails: [.init(
                id: UUID(),
                quantity: 3,
                product: .init(
                    id: UUID(),
                    productId: UUID(),
                    active: true,
                    name: "Test PRoduct",
                    qty: 23,
                    unitType: .unit,
                    unitCost: .init(3450),
                    unitPrice: .init(5650)
                )
            )]
        )
        cartViewModel.cartCoreData = car
    }
    func deleteCartDetail(cartDetail: CartDetail) {
        Task {
//            loading = true
            do {
                try await cartViewModel.deleteCartDetail(cartDetail: cartDetail)
                await cartViewModel.fetchCart()
            } catch {
                router.presentAlert(.error(error.localizedDescription))
            }
//            loading = false
        }
    }
    func decreceProductAmount(cartDetail: CartDetail) {
        Task {
//            loading = true
            do {
                if cartDetail.quantity - 1 <= 0 {
                    try await cartViewModel.deleteCartDetail(cartDetail: cartDetail)
                } else {
                    try await cartViewModel.changeProductAmount(productId: cartDetail.product.id, amount: cartDetail.quantity - 1)
                }
                await cartViewModel.fetchCart()
            } catch {
                router.presentAlert(.error(error.localizedDescription))
            }
//            loading = false
        }
    }
    func increaceProductAmount(cartDetail: CartDetail) {
        Task {
//            loading = true
            do {
                try await cartViewModel.changeProductAmount(productId: cartDetail.product.id, amount: cartDetail.quantity + 1)
                await cartViewModel.fetchCart()
            } catch {
                router.presentAlert(.error(error.localizedDescription))
            }
//            loading = false
        }
    }
}
