//
//  CarritoProductCardView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/04/23.
//

import SwiftUI

struct CarritoProductCardView: View {
    let nombreProducto:String
    let precioUnitarioProducto:Double
    let urlProducto: String
    let cantidadProducto:Double
    
    let size: CGFloat
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
                        Text(nombreProducto)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal,5)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Button(action: {
                            
                        }) {
                            HStack {
                                Image(systemName: "minus")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                            }
                            .padding(12)
                            .foregroundColor(Color("color_background"))
                            .background(Color("color_secondary"))
                            .clipShape(Circle())
                        }
                        
                        HStack {
                            Text("\(cantidadProducto) u")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical,10)
                        .padding(.horizontal,10)
                        .foregroundColor(Color("color_background"))
                        .background(Color("color_secondary"))
                        .cornerRadius(20)
                        
                        Button(action: {

                        }) {
                            HStack {
                                Image(systemName: "plus")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                            }
                            .padding(12)
                            .foregroundColor(Color("color_background"))
                            .background(Color("color_secondary"))
                            .clipShape(Circle())
                        }
                        
                        HStack {
                            Text(String("S/. \(precioUnitarioProducto)"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical,10)
                        .padding(.horizontal,10)
                        .foregroundColor(Color("color_background"))
                        .background(Color("color_secondary"))
                        .cornerRadius(20)
                    }
                }
                .padding(.vertical,10)
                .padding(.trailing,10)
            }
            .frame(maxWidth: .infinity, maxHeight: size)
            .background(Color("color_primary"))
            .cornerRadius(20.0)
        }
        .onAppear{
            imageProductNetwork.getImage(url: (URL(string: urlProducto )!))
        }
    }
}

struct CarritoProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        CarritoProductCardView(nombreProducto: "iPad Pro Max", precioUnitarioProducto: 23.2, urlProducto: "https://falabella.scene7.com/is/image/FalabellaPE/19348069_1?wid=180", cantidadProducto: 34.5, size: 120)
    }
}
