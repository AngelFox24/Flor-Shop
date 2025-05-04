//
//  CarritoView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/04/23.
//

import SwiftUI
import CoreData

struct CartView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @Binding var loading: Bool
    @Binding var showMenu: Bool
    @Binding var tab: Tab
    var body: some View {
        VStack(spacing: 0) {
            CartTopBar(showMenu: $showMenu)
            ListCartController(loading: $loading, tab: $tab)
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
    @Previewable @State var loading: Bool = false
    @Previewable @State var showMenu: Bool = false
    @Previewable @State var tab: Tab = .magnifyingglass
    let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
    let dependencies = BusinessDependencies(sessionConfig: ses)
    CartView(loading: $loading, showMenu: $showMenu, tab: $tab)
        .environmentObject(dependencies.cartViewModel)
}

struct ListCartController: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var navManager: NavManager
    @EnvironmentObject var errorState: ErrorState
    @Binding var loading: Bool
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
        navManager.goToPaymentView()
    }
    func addProductToCart() {
        let car = Car(
            id: UUID(),
            cartDetails: [.init(
                id: UUID(),
                quantity: 3,
                product: .init(
                    id: UUID(),
                    active: true,
                    name: "Test PRoduct",
                    qty: 23,
                    unitType: .unit,
                    unitCost: .init(3450),
                    unitPrice: .init(5650),
                    createdAt: .init(),
                    updatedAt: .init()
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
                await errorState.processError(error: error)
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
                await errorState.processError(error: error)
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
                await errorState.processError(error: error)
            }
//            loading = false
        }
    }
}
