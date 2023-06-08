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
    @ObservedObject var imageProductNetwork = ImageProductNetworkViewModel()
    
    static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            return formatter
        }()
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                /*imageProductNetwork.imageProduct
                    .resizable()
                    .frame(width: size,height: size)
                    .cornerRadius(20.0)
                 */
                AsyncImage(url: URL(string: urlProducto )!){ phase in
                    switch phase {
                    case .empty:
                        Image("ProductoSinNombre")
                            .resizable()
                            .frame(width: size,height: size)
                            .cornerRadius(20.0)
                    case .success(let returnetImage):
                        returnetImage
                            .resizable()
                            .frame(width: size,height: size)
                            .cornerRadius(20.0)
                    case .failure:
                        Image("ProductoSinNombre")
                            .resizable()
                            .frame(width: size,height: size)
                            .cornerRadius(20.0)
                    default:
                        Image("ProductoSinNombre")
                            .resizable()
                            .frame(width: size,height: size)
                            .cornerRadius(20.0)
                    }
                }
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
                        Text("\(Self.dateFormatter.string(from: fechaVencimiento))")
                            .padding(.vertical,10)
                            .padding(.horizontal,10)
                            .foregroundColor(Color("color_background"))
                            .background(Color("color_secondary"))
                            .cornerRadius(20)
                        Spacer()
                        Text(String(cantidadProducto))
                            .padding(.vertical,10)
                            .padding(.horizontal,10)
                            .foregroundColor(Color("color_background"))
                            .background(Color("color_secondary"))
                            .cornerRadius(20)
                        Spacer()
                        Text(String("S/. \(precioUnitarioProducto)"))
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
            //imageProductNetwork.getImage(url: (URL(string: urlProducto )!))
        }
    }
}


struct ProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCardView(nombreProducto: "Paloma", fechaVencimiento: Date(), cantidadProducto: 34.4, precioUnitarioProducto: 23.2, urlProducto: "https://falabella.scene7.com/is/image/FalabellaPE/19348069_1?wid=180", size: 120)
    }
}
