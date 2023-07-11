//
//  CarritoView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/04/23.
//

import SwiftUI
import CoreData

struct CartView: View {
    @Binding var selectedTab: Tab
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                CartTopBar()
                ListCartController(selectedTab: $selectedTab)
            }
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        let carManager = LocalCarManager(containerBDFlor: CoreDataProvider.shared.persistContainer)
        let carRepository = CarRepositoryImpl(manager: carManager)
        CartView(selectedTab: .constant(.cart))
            .environmentObject(CartViewModel(carRepository: carRepository))
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
                    CartProductCardView(productId: cartDetail.product.id, productUrl: cartDetail.product.url, productName: cartDetail.product.name, product: cartDetail.product, productUnitPrice: cartDetail.product.unitPrice, carQuantity: cartDetail.quantity, size: 100, decreceProductAmount: decreceProductAmount, increaceProductAmount: increaceProductAmount)
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
        }
        .padding(.horizontal, 10)
        .background(Color("color_background"))
    }
    func deleteProduct(product: Product) {
        cartViewModel.deleteProduct(product: product)
    }
    func decreceProductAmount(product: Product) {
        cartViewModel.decreceProductAmount(product: product)
    }
    func increaceProductAmount(product: Product) {
        cartViewModel.increaceProductAmount(product: product)
    }
}
