//
//  HomeView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/23.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) private var TB_ProductosVar: FetchedResults<TB_Productos>

    //@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TB_Productos.id, ascending: true)],animation: .default) private var productos_tb: FetchedResults<TB_Productos>
    
    var body: some View {
        ZStack{
            Color("color_background")
                .ignoresSafeArea()
            VStack{
                TopBar()
                ListaControler()
                
            }
            VStack{
                Spacer()
                ButtonPlus()
            }
        }
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
        HStack{
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color("color_icons"))
                    .font(.system(size: 25))
                TextField("Buscar Producto",text: $seach)
                    .foregroundColor(Color("color_icons"))
                    .disableAutocorrection(true)
                
            }
            .padding(.all,10)
            .background(Color("color_primary"))
            .cornerRadius(35.0)
            .padding(.trailing,8)
            
            Button(action: { }) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(Color("color_icons"))
                    .padding(.all,10)
                    .background(Color("color_primary"))
                    .cornerRadius(20.0)
            }
            .font(.title)
            .foregroundColor(Color("color_primary"))
        }
        .padding(.horizontal,30)
        //.overlay(Color.gray.opacity(0.9))
        //.border(Color.red)
    }
}

struct ButtonPlus: View {
    var body: some View {
        HStack {
            Spacer()
            Button(action: { }) {
                Image(systemName: "plus")
                    .foregroundColor(Color("color_icons"))
                    .padding(.all,15)
                    .background(Color("color_primary"))
                    .clipShape(Circle())
            }
            .font(.title)
            .foregroundColor(Color("color_primary"))
        }
        .padding(.horizontal,35)
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

struct ProductoCardView: View {
    var idProducto: String
    var producto: ProductoModel
    let size: CGFloat
    //@EnvironmentObject var muebles: MueblesViewModel
    @ObservedObject var imageProductNetwork = ImageProductNetworkViewModel()
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                imageProductNetwork.imageProduct
                    .resizable()
                    .frame(width: size,height: size)
                    .cornerRadius(20.0)
                VStack {
                    Text(producto.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.bottom,10)
                    Spacer()
                    Text(producto.expiredate)
                        .padding(.top,10)
                }
                .padding(.vertical,10)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity)
                VStack {
                    Text(String(producto.quantity))
                    //.frame(width: 55, height: 20)
                        .padding(.vertical,10)
                        .padding(.horizontal,10)
                        .fontWeight(.bold)
                        .foregroundColor(Color("color_icons"))
                        .background(Color("color_secondary"))
                        .cornerRadius(10)
                    Text(String("S/. \(producto.price)"))
                    //.frame(width: 55, height: 20)
                        .padding(.vertical,10)
                        .padding(.horizontal,10)
                        .fontWeight(.bold)
                        .foregroundColor(Color("color_icons"))
                        .background(Color("color_secondary"))
                        .cornerRadius(10)
                }
                .padding(.trailing)
            }
            .frame(maxWidth: .infinity, maxHeight: size)
            .background(Color("color_primary"))
            .cornerRadius(20.0)
            .padding(.horizontal,15)
            
        }.onAppear{
            imageProductNetwork.getImage(url: (URL(string: producto.imageURL )!))
            //imagencita=mueble.imagenRenderizada
            //muebles.guardarImagenRenderizada(idMuebleInput: mueble.id, imagenInput: imagenMuebleNetwork.fotoMueble)
            //mueble.imagenRenderizada = imagenMuebleNetwork.fotoMueble
            //Task.sleep(nanoseconds: 3_000_000_000)
            //muebles.muebles[mueble.id-1].imagenRenderizada = imagenMuebleNetwork.fotoMueble
            
        }
    }
}

