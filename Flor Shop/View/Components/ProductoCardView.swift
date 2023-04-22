//
//  ProductCardView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/04/23.
//

import SwiftUI

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

struct ProductoCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductoCardView(idProducto: "1",producto: ProductoModel(id: "0", expiredate: "29/03/2023", imageURL: "https://falabella.scene7.com/is/image/FalabellaPE/882760327_2?wid=240&hei=240&qlt=70&fmt=webp", name: "Mocasin", price: 78.90, quantity: 34), size: 120.0)
    }
}
