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
                VStack{
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
    }
}

struct ListaControler: View {
    @EnvironmentObject var productos: ProductoListViewModel
    var body: some View {
        ScrollView(.vertical,showsIndicators: false){
            
            VStack{
                ForEach(productos.productosDiccionario.sorted(by: { $0.0 < $1.0 }), id: \.key){idProducto,producto in
                    ProductoCardView(idProducto: idProducto, producto: producto, size: 120.0)
                    /*NavigationLink(
                     
                     destination: DetailScreen(mueble: mueble),
                     
                     label: {
                     ProductoCardView(size: 120.0)
                     
                     })
                     .navigationBarHidden(true)
                     .foregroundColor(.black)
                     
                     }*/
                }
            }
        }
    }
}



