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
                            .font(.custom("text_font_1", size: 16))
                            .lineLimit(2)
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
                }
                .padding(.bottom,6)
                VStack {
                    HStack(spacing: 0) {
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
                .padding(.horizontal,10)
            }
            .frame(maxWidth: .infinity, maxHeight: size)
            .background(.white)
        }
        .cornerRadius(15)
    }
}


struct ProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCardView(id: UUID(uuidString: "3062F3B7-14C7-4314-B342-1EC912EBD925") ?? UUID(), name: "Bombones de chocolate Bon O Bon corazón 105", expirationDate: Date(), quantity: 34.4, unitPrice: 23.2, url: "https://falabella.scene7.com/is/image/FalabellaPE/882430431_1?wid=180", size: 100)
    }
}
