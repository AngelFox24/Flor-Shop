import SwiftUI
import FlorShopDTOs

struct CartView: View {
    @Environment(FlorShopRouter.self) private var router
    @Environment(OverlayViewModel.self) private var overlayViewModel
    @State var cartViewModel: CartViewModel
    init(ses: SessionContainer) {
        cartViewModel = CartViewModelFactory.getCartViewModel(sessionContainer: ses)
    }
    var body: some View {
        ListCartController(cartViewModel: $cartViewModel, backAction: router.back)
            .navigationTitle("Carrito")
            .navigationSubtitle(Text("\(cartViewModel.customerInCar?.name, default: "Cliente desconocido")"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CartTopToolbar(cartViewModel: $cartViewModel, scannerAction: addProductInCart)
            }
            .task {
                await cartViewModel.fetchCart()
            }
    }
    func addProductInCart(barcode: String) {
        let loadingId = self.overlayViewModel.showLoading(origin: "[SaleListProductView]")
        Task {
            do {
                try await cartViewModel.addProductInCart(barcode: barcode)
                await cartViewModel.fetchCart()
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

#Preview {
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    CartView(ses: SessionContainer.preview)
        .environment(mainRouter)
}

struct ListCartController: View {
    @Environment(OverlayViewModel.self) private var overlayViewModel
    @Binding var cartViewModel: CartViewModel
    let backAction: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            if let cart = cartViewModel.cartCoreData {
                List {
                    ForEach(cart.cartDetails) { cartDetail in
                        Button {
                            self.showEditAmountView(
                                cartDetailId: cartDetail.id,
                                productName: cartDetail.product.name,
                                imageUrl: cartDetail.product.imageUrl,
                                unitType: cartDetail.product.unitType,
                                initialAmount: cartDetail.quantity
                            )
                        } label: {
                            CartCardView(
                                cartDetailId: cartDetail.id,
                                imageUrl: cartDetail.product.imageUrl,
                                productName: cartDetail.product.name,
                                mainIndicatorPrefix: "S/. ",
                                mainIndicator: cartDetail.product.unitPrice.solesString,
                                secondaryIndicatorSuffix: " \(cartDetail.product.unitType.shortDescription)",
                                secondaryIndicator: cartDetail.quantityDisplay,
                                decreceProductAmount: decreceProductAmount,
                                increaceProductAmount: increaceProductAmount
                            )
                        }
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
//                    let _ = print("[ListCartController] total: \(total)")
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
    func showEditAmountView(cartDetailId: UUID, productName: String, imageUrl: String?, unitType: UnitType, initialAmount: Int) {
        self.overlayViewModel.showEditAmountView(imageUrl: imageUrl, confirm: EditAction(title: productName) { amount in
            self.editProductAmount(cartDetailId: cartDetailId, newAmount: amount)
        }, type: unitType, initialAmount: initialAmount)
    }
    func deleteCartDetail(cartDetailId: UUID) {
        Task {
            do {
                try await cartViewModel.deleteCartDetail(cartDetailId: cartDetailId)
                await cartViewModel.fetchCart()
            } catch {
                print("[ListCartController] Error al eliminar el producto: \(error.localizedDescription)")
            }
        }
    }
    func decreceProductAmount(cartDetailId: UUID) {
        Task {
            do {
                try await cartViewModel.stepProductAmount(cartDetailId: cartDetailId, type: .decrease)
                await cartViewModel.fetchCart()
            } catch {
                print("[ListCartController] Error al reducir la cantidad: \(error.localizedDescription)")
            }
        }
    }
    func increaceProductAmount(cartDetailId: UUID) {
        Task {
            do {
                try await cartViewModel.stepProductAmount(cartDetailId: cartDetailId, type: .increase)
                await cartViewModel.fetchCart()
            } catch {
                print("[ListCartController] Error al aumentar la cantidad: \(error.localizedDescription)")
            }
        }
    }
    func editProductAmount(cartDetailId: UUID, newAmount: Int) {
        let loadingId = self.overlayViewModel.showLoading(origin: "[ListCartController]")
        Task {
            do {
                try await cartViewModel.changeProductAmount(cartDetailId: cartDetailId, amount: newAmount)
                await cartViewModel.fetchCart()
                self.overlayViewModel.endLoading(id: loadingId, origin: "[ListCartController]")
            } catch {
               print("Error al modificar la cantidad: \(error.localizedDescription)")
                self.overlayViewModel.showAlert(
                    title: "Error",
                    message: "Ha ocurrido un error al modificar la cantidad. Por favor, intente nuevamente.",
                    primary: ConfirmAction(
                        title: "Aceptar",
                        action: {
                            self.overlayViewModel.endLoading(id: loadingId, origin: "[ListCartController]")
                        }
                    )
                )
            }
        }
    }
}
