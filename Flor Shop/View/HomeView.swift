//
//  HomeView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/23.
//

import SwiftUI

struct HomeView: View {
    let viewName = "BuscarView"
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) private var TB_ProductosVar: FetchedResults<TB_Productos>
    
    //@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TB_Productos.id, ascending: true)],animation: .default) private var productos_tb: FetchedResults<TB_Productos>
    
    var body: some View {
        NavigationView () {
            ZStack{
                Color("color_background")
                    .ignoresSafeArea()
                VStack{
                    TopBar()
                    ListaControler()
                    BottonBar(vista: viewName)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        //.ignoresSafeArea()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(ProductoListViewModel())
    }
}

struct TopBar: View {
    @State private var seach:String = ""
    var body: some View {
        
            VStack {
                HStack{
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color("color_primary"))
                            .font(.system(size: 25))
                        TextField("Buscar Producto",text: $seach)
                            .foregroundColor(Color("color_primary"))
                            .disableAutocorrection(true)
                        
                    }
                    .padding(.all,10)
                    .background(Color("color_background"))
                    .cornerRadius(35.0)
                    .padding(.trailing,8)
                    
                    Button(action: { }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(Color("color_primary"))
                            .padding(.horizontal,8)
                            .padding(.vertical,10)
                            .background(Color("color_background"))
                            .cornerRadius(15.0)
                    }
                    .font(.title)
                    //.foregroundColor(Color("color_background"))
                }
                .padding(.horizontal,30)
            }
            .padding(.bottom,10)
            .background(Color("color_primary"))
        
        //.overlay(Color.gray.opacity(0.9))
        //.border(Color.red)
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



