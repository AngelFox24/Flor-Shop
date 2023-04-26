//
//  ProductCardView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 25/04/23.
//
//  Por ahora solo trabaja con CoreData
//  TODO: Implementar Merge con la API

import SwiftUI

struct ProductCardView: View {
    //var producto: ProductoEntity
    let nombreProducto:String
    let fechaVencimiento:Date
    let cantidadProducto:Double
    let precioUnitarioProducto:Double
    let urlProducto: String
    
    
    let size: CGFloat
    //@EnvironmentObject var muebles: MueblesViewModel
    @ObservedObject var imageProductNetwork = ImageProductNetworkViewModel()
    
    static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            return formatter
        }()
    
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
                            //.lineLimit(2)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal,5)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Text("\(Self.dateFormatter.string(from: fechaVencimiento))")
                        //.frame(width: 55, height: 20)
                            .padding(.vertical,10)
                            .padding(.horizontal,10)
                            //.fontWeight(.bold)
                            .foregroundColor(Color("color_background"))
                            .background(Color("color_secondary"))
                            .cornerRadius(20)
                        Spacer()
                        Text(String(cantidadProducto))
                        //.frame(width: 55, height: 20)
                            .padding(.vertical,10)
                            .padding(.horizontal,10)
                            //.fontWeight(.bold)
                            .foregroundColor(Color("color_background"))
                            .background(Color("color_secondary"))
                            .cornerRadius(20)
                        Spacer()
                        Text(String("S/. \(precioUnitarioProducto)"))
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
            imageProductNetwork.getImage(url: (URL(string: urlProducto )!))
        }
    }
}

/*
struct ProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        let newProduct = ProductoEntity()
        ProductCardView(idProducto: "1", producto: newProduct, size: 100)
    }
}*/
