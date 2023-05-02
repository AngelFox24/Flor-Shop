//
//  CarritoView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/04/23.
//

import SwiftUI

struct CarritoView: View {
    @State var sumaTotal:Double = 56.50
    var body: some View {
        NavigationView () {
            ZStack{
                Color("color_background")
                    .ignoresSafeArea()
                VStack(spacing: 0){
                    CarritoTopBar(totalText: $sumaTotal)
                    ListaCarritoControler()
                }
            }
        }
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CarritoView_Previews: PreviewProvider {
    static var previews: some View {
        CarritoView()
            .environmentObject(ProductoListViewModel())
            .environmentObject(ProductoCoreDataViewModel())
    }
}

struct ListaCarritoControler: View {
    @EnvironmentObject var productosCoreDataViewModel: ProductoCoreDataViewModel
    var body: some View {
        VStack {
            List(){
                ForEach(productosCoreDataViewModel.productosCoreData){producto in
                    CarritoProductCardView(nombreProducto: producto.nombre_producto ?? "No hay producto",  precioUnitarioProducto: producto.precio_unitario, urlProducto: producto.url ?? "", cantidadProducto: producto.cantidad,size: 120.0)
                        .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                }
                .onDelete(perform: productosCoreDataViewModel.deleteProduct)
            }
            .listStyle(PlainListStyle())
        }
    }
}
