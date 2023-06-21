//
//  CarritoView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/04/23.
//

import SwiftUI
import CoreData

struct CartView: View {
    var body: some View {
        NavigationView () {
            ZStack{
                Color("color_background")
                    .ignoresSafeArea()
                VStack(spacing: 0){
                CartTopBar()
                ListCartController()
                }
            }
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        let carManager = LocalCarManager(containerBDFlor: CoreDataProvider.shared.persistContainer)
        let carRepository = CarRepositoryImpl(manager: carManager)
        CartView()
            .environmentObject(CartViewModel(carRepository: carRepository))
    }
}
struct ListCartController: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    var body: some View {
        VStack {
            List(){
                ForEach(cartViewModel.cartDetailCoreData) { cartDetail in
                    CartProductCardView(cartDetail: cartDetail, size: 100.0, decreceProductAmount: decreceProductAmount, increaceProductAmount: increaceProductAmount)
                        .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        .listRowBackground(Color("color_background"))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive, action: {
                                deleteProduct(product: cartDetail.product)
                            }) {
                                Image(systemName: "trash")
                            }
                            .tint(Color("color_accent"))
                        }
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
        }
        .padding(.horizontal, 10)
        .background(Color("color_background"))
    }
    func deleteProduct(product: Product) {
        cartViewModel.deleteProduct(product: product)
    }
    func decreceProductAmount(product: Product){
        cartViewModel.decreceProductAmount(product: product)
    }
    func increaceProductAmount(product: Product){
        cartViewModel.increaceProductAmount(product: product)
    }
}
