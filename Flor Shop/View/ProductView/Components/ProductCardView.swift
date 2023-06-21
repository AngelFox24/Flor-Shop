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
    let name: String
    let expirationDate: Date
    let quantity: Double
    let unitPrice: Double
    let url: String
    let size: CGFloat
    //@ObservedObject var imageProductNetwork = ImageProductNetworkViewModel()
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack{
            HStack{
                let _ = print ("Producto gg")
                CustomAsyncImageView(id: id, urlProducto: url, size: size)
                VStack {
                    HStack { //Nombre Producto
                        Text(name)
                            .font(.headline)
                            .fontWeight(.bold) // Alinea el texto a la izquierda
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    HStack { //Cantidad Producto
                        Text(String("\(quantity) u"))
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
                        Text(String(unitPrice))
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
    }
}


struct ProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCardView(id: UUID(uuidString: "3062F3B7-14C7-4314-B342-1EC912EBD925") ?? UUID(), name: "Bombones de chocolate Bon O Bon corazón 105", expirationDate: Date(), quantity: 34.4, unitPrice: 23.2, url: "https://s7d2.scene7.com/is/image/TottusPE/42762662_0?wid=136&hei=136&qlt=70", size: 100)
    }
}
