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
                    HStack {
                        Text(producto.name)
                            //.lineLimit(2)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal,5)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Text(String("\(producto.expiredate)"))
                        //.frame(width: 55, height: 20)
                            .padding(.vertical,10)
                            .padding(.horizontal,10)
                            //.fontWeight(.bold)
                            .foregroundColor(Color("color_background"))
                            .background(Color("color_secondary"))
                            .cornerRadius(20)
                        Spacer()
                        Text(String(producto.quantity))
                        //.frame(width: 55, height: 20)
                            .padding(.vertical,10)
                            .padding(.horizontal,10)
                            //.fontWeight(.bold)
                            .foregroundColor(Color("color_background"))
                            .background(Color("color_secondary"))
                            .cornerRadius(20)
                        Spacer()
                        Text(String("S/. \(producto.price)"))
                        //.frame(width: 55, height: 20)
                            .padding(.vertical,10)
                            .padding(.horizontal,10)
                            //.fontWeight(.bold)
                            .foregroundColor(Color("color_background"))
                            .background(Color("color_secondary"))
                            .cornerRadius(20)
                    }
                }
                .padding(.vertical,10)
                .padding(.trailing,10)
                //.multilineTextAlignment(.leading)
                //.frame(maxWidth: .infinity)
                
            }
            .frame(maxWidth: .infinity, maxHeight: size)
            .background(Color("color_primary"))
            .cornerRadius(20.0)
            .padding(.horizontal,15)
            
        }.onAppear{
            imageProductNetwork.getImage(url: (URL(string: producto.imageURL )!))
        }
    }
}

struct ProductoCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductoCardView(idProducto: "1",producto: ProductoModel(id: "0", expiredate: "29/03/2023", imageURL: "https://falabella.scene7.com/is/image/FalabellaPE/882760327_2?wid=240&hei=240&qlt=70&fmt=webp", name: "Use este modificador para diferenciar entre ciertas vistas seleccionables, como los valores posibles de un Picker o las pestañas de un TabView. Los valores de etiqueta pueden ser de cualquier tipo que se ajuste al protocolo Hashable.En el siguiente ejemplo, el bucle ForEach en el generador de vistas Picker itera sobre la enumeración Flavor.", price: 78.90, quantity: 34), size: 120.0)
    }
}
