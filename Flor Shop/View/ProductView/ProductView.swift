//
//  HomeView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/23.
//

import SwiftUI
import CoreData

struct ProductView: View {
    var body: some View {
        NavigationView () {
            ZStack{
                Color("color_background")
                    .ignoresSafeArea()
                VStack(spacing: 0){
                    BuscarTopBar()
                    ListaControler()
                }
            }
        }
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ProductView()
            .environmentObject(ProductCoreDataViewModel(contenedorBDFlor: NSPersistentContainer(name: "BDFlor")))
            .environmentObject(CarritoCoreDataViewModel(contenedorBDFlor: NSPersistentContainer(name: "BDFlor")))
    }
}

struct ListaControler: View {
    @EnvironmentObject var productsCoreDataViewModel: ProductCoreDataViewModel
    @EnvironmentObject var carritoCoreDataViewModel: CarritoCoreDataViewModel
    var body: some View {
        
        VStack {
            List(){
                ForEach(productsCoreDataViewModel.productsCoreData){producto in
                    ProductCardView(
                        nombreProducto: producto.nombreProducto ?? "No hay producto",
                        fechaVencimiento: producto.fechaVencimiento ?? Date(),
                        cantidadProducto: producto.cantidadStock,
                        precioUnitarioProducto: producto.precioUnitario,
                        urlProducto: producto.url ?? "",
                        size: 120.0)
                        .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button(action: {
                                agregarProductoACarrito(producto: producto)
                            }) {
                                Image(systemName: "heart.fill")
                            }
                            .tint(.red)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(action: {
                                editarProducto(producto: producto)
                            }) {
                                Image(systemName: "trash")
                            }
                            .tint(.red)
                        }
                }
                
            }
            .listStyle(PlainListStyle())
            
        }
    }
    func editarProducto(producto: Tb_Producto){
        //productsCoreDataViewModel.productsCoreData.
        print("Se edito el producto \(producto.nombreProducto ?? "No se sabe xd")")
    }
    func agregarProductoACarrito(producto: Tb_Producto){
        carritoCoreDataViewModel.addProductoToCarrito(productoEntity: producto)
        print("Se agrego el producto al carrito \(producto.nombreProducto ?? "No se sabe")")
    }
}
