//
//  HomeView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/23.
//

import SwiftUI

struct BuscarView: View {
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
        BuscarView()
            .environmentObject(ProductoListViewModel())
            .environmentObject(ProductoCoreDataViewModel())
            .environmentObject(ProductCoreDataViewModel())
    }
}

struct ListaControler: View {
    @EnvironmentObject var productos: ProductoListViewModel
    @EnvironmentObject var productsCoreDataViewModel: ProductCoreDataViewModel
    var body: some View {
        
        VStack {
            List(){
                ForEach(productsCoreDataViewModel.productsCoreData){producto in
                    ProductCardView(nombreProducto: producto.nombreProducto ?? "No hay producto", fechaVencimiento: producto.fechaVencimiento ?? Date(), cantidadProducto: producto.cantidadStock, precioUnitarioProducto: producto.precioUnitario, urlProducto: producto.url ?? "", size: 120.0)
                        .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                }
                .onDelete(perform: productsCoreDataViewModel.deleteProduct)
            }
            .listStyle(PlainListStyle())
        }
        //}
    }
}
