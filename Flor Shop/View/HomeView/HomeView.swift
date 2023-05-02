//
//  HomeView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/23.
//

import SwiftUI

struct HomeView: View {
    //@Environment(\.managedObjectContext) private var viewContext
    //@FetchRequest(sortDescriptors: []) private var TB_ProductosVar: FetchedResults<TB_Productos>
    
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
        HomeView()
            .environmentObject(ProductoListViewModel())
            .environmentObject(ProductoCoreDataViewModel())
    }
}

struct ListaControler: View {
    @EnvironmentObject var productos: ProductoListViewModel
    @EnvironmentObject var productosCoreDataViewModel: ProductoCoreDataViewModel
    var body: some View {
        
        VStack {
            List(){
                ForEach(productosCoreDataViewModel.productosCoreData){producto in
                    ProductCardView(nombreProducto: producto.nombre_producto ?? "No hay producto", fechaVencimiento: producto.fecha_vencimiento ?? Date(), cantidadProducto: producto.cantidad, precioUnitarioProducto: producto.precio_unitario, urlProducto: producto.url ?? "", size: 120.0)
                        .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                }
                .onDelete(perform: productosCoreDataViewModel.deleteProduct)
            }
            .listStyle(PlainListStyle())
        }
        //}
    }
}
