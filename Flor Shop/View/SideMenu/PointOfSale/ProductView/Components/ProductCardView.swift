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
    let expirationDate: Date?
    let quantity: Int
    let unitPrice: Double
    let url: String
    let size: CGFloat
    var body: some View {
        VStack {
            HStack {
                CustomAsyncImageView(id: id, urlProducto: url, size: size)
                VStack {
                    HStack { // Nombre Producto
                        Text(name)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 16))
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .padding(.top, 6)
                    HStack { // Cantidad Producto
                        Text(String(quantity)+" u")
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 16))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Color("color_secondary"))
                            .cornerRadius(20)
                        Spacer()
                    }
                }
                .padding(.bottom, 6)
                VStack {
                    HStack(spacing: 0) {
                        Text(String("S/. "))
                            .font(.custom("Artifika-Regular", size: 15))
                        Text(String(unitPrice))
                            .font(.custom("Artifika-Regular", size: 18))
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .foregroundColor(.white)
                    .background(Color("color_accent"))
                    .cornerRadius(20)
                }
                .padding(.horizontal, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: size)
            .background(.white)
        }
        .cornerRadius(15)
    }
}

struct ProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCardView(id: UUID(uuidString: "3062F3B7-14C7-4314-B342-1EC912EBD925") ?? UUID(), name: "AUDIFONOS C NOISE CANCELLING 1000XM4BMUC", expirationDate: Date(), quantity: 34, unitPrice: 23.2, url: "https://falabella.scene7.com/is/image/FalabellaPE/882430431_1?wid=180", size: 100)
    }
}
