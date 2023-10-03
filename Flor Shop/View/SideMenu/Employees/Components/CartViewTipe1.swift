//
//  CartViewTipe1.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 26/09/23.
//

import SwiftUI

struct CardViewTipe1: View {
    //No se declara modelos de datos de capa vista porque se reutilizara para varias vistas
    let image: ImageUrl
    let topStatusColor: Color
    let topStatus: String
    let mainText: String
    let secondaryText: String
    let size: CGFloat
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                CustomAsyncImageView(id: image.id, urlProducto: image.imageUrl, size: size)
                VStack(spacing: 2) {
                    HStack{
                        topStatusColor
                            .frame(width: 10, height: 10)
                            .cornerRadius(15)
                        Text(topStatus)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 9))
                        Spacer()
                    }
                    HStack {
                        Text(mainText)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 16))
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                    HStack {
                        Text(secondaryText)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 11))
                        Spacer()
                    }
                }
                .padding(.vertical, 6)
                HStack{
                    Image(systemName: "chevron.backward")
                        .foregroundColor(Color("color_accent"))
                        .font(.custom("Artifika-Regular", size: 22))
                        .rotationEffect(.degrees(180))
                        .padding(.horizontal, 12)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: size)
            .background(.white)
        }
        .cornerRadius(15)
    }
}

struct CardViewTipe1_Previews: PreviewProvider {
    static var previews: some View {
        CardViewTipe1(image: ImageUrl.getDummyImage(), topStatusColor: Color(.red), topStatus: "Manager", mainText: "Pedro Gonzales", secondaryText: "Flor Shop - Santa Anita", size: 80)
            .frame(maxHeight: .infinity)
            .background(Color.gray)
    }
}
