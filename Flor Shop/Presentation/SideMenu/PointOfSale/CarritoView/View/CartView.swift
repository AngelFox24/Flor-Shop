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
    @Binding var selectedTab: Tab
    var body: some View {
        VStack(spacing: 0) {
            CartTopBar()
            ListCartController(selectedTab: $selectedTab)
        }
        .onAppear {
            cartViewModel.lazyFetchCart()
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let nor = NormalDependencies()
        let dependencies = BusinessDependencies(sessionConfig: ses)
        CartView(selectedTab: .constant(.cart))
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(nor.viewStates)
    }
}
struct ListCartController: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var navManager: NavManager
    @EnvironmentObject var viewStates: ViewStates
    @Binding var selectedTab: Tab
    var body: some View {
        VStack(spacing: 0) {
            if let cart = cartViewModel.cartCoreData {
                HStack(spacing: 0,
                       content: {
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
                })
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
                        selectedTab = .magnifyingglass
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
        selectedTab = .magnifyingglass
    }
    func goToPay() {
        navManager.goToPaymentView()
    }
    func deleteCartDetail(cartDetail: CartDetail) {
        Task {
            viewStates.isLoading = true
            await cartViewModel.deleteCartDetail(cartDetail: cartDetail)
            viewStates.isLoading = false
        }
    }
    func decreceProductAmount(cartDetail: CartDetail) {
        Task {
            viewStates.isLoading = true
            await cartViewModel.changeProductAmount(cartDetail: cartDetail)
            viewStates.isLoading = false
        }
    }
    func increaceProductAmount(cartDetail: CartDetail) {
        Task {
            viewStates.isLoading = true
            await cartViewModel.changeProductAmount(cartDetail: cartDetail)
            viewStates.isLoading = false
        }
    }
}
