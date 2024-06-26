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
    let product: Product
    let size: CGFloat
    var body: some View {
        VStack {
            HStack {
                let _ = print("ProductID: \(product.id) y ImagenID: \(product.image.id)")
                CustomAsyncImageView(id: product.image.id, urlProducto: product.image.imageUrl, size: size)
                VStack {
                    HStack { // Nombre Producto
                        Text(product.name)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 16))
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .padding(.top, 6)
                    HStack { // Cantidad Producto
                        Text(String(product.qty)+" u")
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
                        Text(String(product.unitPrice))
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
        ProductCardView(product: Product.getDummyProduct(), size: 80)
    }
}
