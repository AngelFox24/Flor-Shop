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
                ListCartController(selectedTab: $selectedTab)
            }
            .onAppear {
                cartViewModel.lazyFetchCart()
            }
        //}
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        CartView(selectedTab: .constant(.cart), showMenu: .constant(false))
            .environmentObject(dependencies.cartViewModel)
    }
}
struct ListCartController: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @Binding var selectedTab: Tab
    var body: some View {
        VStack(spacing: 0) {
            if cartViewModel.cartDetailCoreData.count == 0 {
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
            } else {
                List {
                    ForEach(cartViewModel.cartDetailCoreData) { cartDetail in
                        //Enviar CartDeail en vez de product al increace o decrece
                        CardViewTipe3(cartDetail: cartDetail, size: 80, decreceProductAmount: decreceProductAmount, increaceProductAmount: increaceProductAmount)
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
            }
        }
        .padding(.horizontal, 10)
        .background(Color("color_background"))
    }
    func deleteCartDetail(cartDetail: CartDetail) {
        cartViewModel.deleteCartDetail(cartDetail: cartDetail)
    }
    func decreceProductAmount(cartDetail: CartDetail) {
        cartViewModel.decreceProductAmount(cartDetail: cartDetail)
    }
    func increaceProductAmount(cartDetail: CartDetail) {
        cartViewModel.increaceProductAmount(cartDetail: cartDetail)
    }
}
