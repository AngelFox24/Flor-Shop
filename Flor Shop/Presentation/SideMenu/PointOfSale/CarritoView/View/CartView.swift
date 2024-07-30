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
    @Binding var showMenu: Bool
    var body: some View {
        //NavigationView {
            VStack(spacing: 0) {
                CartTopBar(showMenu: $showMenu)
                ListCartController(showMenu: $showMenu, selectedTab: $selectedTab)
            }
            .onAppear {
                cartViewModel.lazyFetchCart()
            }
        //}
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        CartView(selectedTab: .constant(.cart), showMenu: .constant(false))
            .environmentObject(dependencies.cartViewModel)
    }
}
struct ListCartController: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var navManager: NavManager
    @EnvironmentObject var loadingState: LoadingState
    @Binding var showMenu: Bool
    @Binding var selectedTab: Tab
    @State var isPresented = false
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
                                .alert(cartViewModel.error, isPresented: $isPresented, actions: {})
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
            loadingState.isLoading = true
            await cartViewModel.deleteCartDetail(cartDetail: cartDetail)
            loadingState.isLoading = false
        }
    }
    func decreceProductAmount(cartDetail: CartDetail) {
        Task {
            loadingState.isLoading = true
            await cartViewModel.changeProductAmount(cartDetail: cartDetail)
            loadingState.isLoading = false
        }
    }
    func increaceProductAmount(cartDetail: CartDetail) {
        Task {
            loadingState.isLoading = true
            await cartViewModel.changeProductAmount(cartDetail: cartDetail)
            loadingState.isLoading = false
        }
    }
}
