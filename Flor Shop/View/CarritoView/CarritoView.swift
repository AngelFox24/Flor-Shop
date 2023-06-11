//
//  CarritoView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/04/23.
//

import SwiftUI
import CoreData

struct CarritoView: View {
    var body: some View {
        NavigationView () {
            ZStack{
                Color("color_background")
                    .ignoresSafeArea()
                VStack(spacing: 0){
                CarritoTopBar()
                ListaCarritoControler()
                }
            }
        }
    }
}

struct CarritoView_Previews: PreviewProvider {
    static var previews: some View {
        let carManager = LocalCarManager(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
        let carRepository = CarRepositoryImpl(manager: carManager)
        CarritoView()
            .environmentObject(CarritoCoreDataViewModel(carRepository: carRepository))
    }
}

struct ListaCarritoControler: View {
    @EnvironmentObject var carritoCoreDataViewModel: CarritoCoreDataViewModel
    var body: some View {
        VStack {
            List(){
                ForEach(carritoCoreDataViewModel.getListProductInCart()) { cartDetail in
                    CarritoProductCardView(cartDetail: cartDetail, size: 100.0, decreceProductAmount: decreceProductAmount, increaceProductAmount: increaceProductAmount)
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
        carritoCoreDataViewModel.deleteProduct(product: product)
        print("Se elimino un producto del carrito \(product.name)")
    }
    func decreceProductAmount(product: Product){
        carritoCoreDataViewModel.decreceProductAmount(product: product)
    }
    func increaceProductAmount(product: Product){
        carritoCoreDataViewModel.increaceProductAmount(product: product)
    }
}
