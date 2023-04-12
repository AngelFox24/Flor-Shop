//
//  HomeView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/23.
//

import SwiftUI

struct HomeView: View {
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
    var body: some View {
        ScrollView(.vertical,showsIndicators: false){
            
            VStack{
                ForEach(1..<11, id: \.self){index in
                    ProductoCardView(size: 120.0)
                    /*NavigationLink(
                     
                     //destination: DetailScreen(mueble: mueble),
                     
                     label: {
                     ProductoCardView(size: 120.0)
                     
                     })
                     .navigationBarHidden(true)
                     .foregroundColor(.black)
                     
                     }
                     .padding(.leading)*/
                }
            }
        }
    }
}

struct ProductoCardView: View {
    //var mueble: Mueble
    //@EnvironmentObject var muebles: MueblesViewModel
    //@ObservedObject var imagenMuebleNetwork = NetworkModelMueble()
    
    let size: CGFloat
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Image("papas_lays_clasic")
                    .resizable()
                    .frame(width: size,height: size)
                    .cornerRadius(20.0)
                VStack {
                    Text("Papas")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.bottom,10)
                    Spacer()
                    Text("FV 27/09/2023")
                        .padding(.top,10)
                }
                .padding(.vertical,10)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity)
                VStack {
                    Text(String("23 u"))
                    //.frame(width: 55, height: 20)
                        .padding(.vertical,10)
                        .padding(.horizontal,10)
                        .fontWeight(.bold)
                        .foregroundColor(Color("color_icons"))
                        .background(Color("color_secondary"))
                        .cornerRadius(10)
                    Text(String("S/. 6.90"))
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
            //imagenMuebleNetwork.getImage(url: mueble.rutaFoto)
            //imagencita=mueble.imagenRenderizada
            //muebles.guardarImagenRenderizada(idMuebleInput: mueble.id, imagenInput: imagenMuebleNetwork.fotoMueble)
            //mueble.imagenRenderizada = imagenMuebleNetwork.fotoMueble
            //Task.sleep(nanoseconds: 3_000_000_000)
            //muebles.muebles[mueble.id-1].imagenRenderizada = imagenMuebleNetwork.fotoMueble
            
        }
    }
}

