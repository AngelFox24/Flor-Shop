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
    let id: UUID
    let nombreProducto: String
    let fechaVencimiento: Date
    let cantidadProducto: Double
    let precioUnitarioProducto: Double
    let urlProducto: String
    let size: CGFloat
    @ObservedObject var imageProductNetwork = ImageProductNetworkViewModel()
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack{
            HStack{
                if let imageC = imageProductNetwork.imageProduct {
                    let _ = print ("Cargado")
                    imageC
                        .resizable()
                        .frame(width: size,height: size)
                        .cornerRadius(20.0)
                }else {
                    let _ = print ("Holder a cargar")
                    let _ = imageProductNetwork.getImage(id: id,url: (URL(string: urlProducto )!))
                    Image("ProductoSinNombre")
                        .resizable()
                        .frame(width: size,height: size)
                        .cornerRadius(20.0)
                }
                /*AsyncImage(url: URL(string: urlProducto)){ phase in //Imagen Producto
                 switch phase {
                 case .empty:
                 Image("ProductoSinNombre")
                 .resizable()
                 .frame(width: size,height: size)
                 .cornerRadius(15)
                 case .success(let returnetImage):
                 returnetImage
                 .resizable()
                 .frame(width: size,height: size)
                 .cornerRadius(15)
                 case .failure:
                 Image("ProductoSinNombre")
                 .resizable()
                 .frame(width: size,height: size)
                 .cornerRadius(15)
                 default:
                 Image("ProductoSinNombre")
                 .resizable()
                 .frame(width: size,height: size)
                 .cornerRadius(15)
                 }
                 }*/
                VStack {
                    HStack { //Nombre Producto
                        Text(nombreProducto)
                            .font(.headline)
                            .fontWeight(.bold) // Alinea el texto a la izquierda
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    HStack { //Cantidad Producto
                        Text(String("\(cantidadProducto) u"))
                            .font(.custom("text_font_1", size: 18))
                            .padding(.vertical,5)
                            .padding(.horizontal,10)
                            .background(Color("color_secondary"))
                            .cornerRadius(20)
                        Spacer()
                    }
                    .padding(.all, 5)
                }
                VStack {
                    HStack {
                        Text(String("S/. "))
                            .font(.custom("text_font_1", size: 15))
                        Text(String(precioUnitarioProducto))
                            .font(.custom("text_font_1", size: 18))
                    }
                    .padding(.vertical,8)
                    .padding(.horizontal,10)
                    .foregroundColor(.white)
                    .background(Color("color_accent"))
                    .cornerRadius(20)
                }
                .padding(.trailing,10)
            }
            .frame(maxWidth: .infinity, maxHeight: size)
            .background(.white)
        }
        .cornerRadius(15)
        .onAppear{
            imageProductNetwork.getImage(id: id,url: (URL(string: urlProducto )!))
        }
    }
}


struct ProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCardView(id: UUID(uuidString: "3062F3B7-14C7-4314-B342-1EC912EBD925") ?? UUID(), nombreProducto: "Bombones de chocolate Bon O Bon corazón 105", fechaVencimiento: Date(), cantidadProducto: 34.4, precioUnitarioProducto: 23.2, urlProducto: "https://falabella.scene7.com/is/image/FalabellaPE/19348069_1?wid=1800", size: 100)
    }
}
