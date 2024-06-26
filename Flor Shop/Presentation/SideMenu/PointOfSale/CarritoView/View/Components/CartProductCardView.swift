//
//  CartProductCardView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/04/23.
//

import SwiftUI
import CoreData

struct CartProductCardView: View {
    // let cartDetail: CartDetail
    // TODO: Corregir el calculo del total al actualizar precio en AgregarView
    let cartDetail: CartDetail
    let size: CGFloat
    var decreceProductAmount: (CartDetail) -> Void
    var increaceProductAmount: (CartDetail) -> Void
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                CustomAsyncImageView(id: cartDetail.product.image.id, urlProducto: cartDetail.product.image.imageUrl, size: size)
                VStack {
                    HStack {
                        Text(cartDetail.product.name)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 16))
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .padding(.top, 6)
                    HStack {
                        Button(action: {}, label: {
                            Image(systemName: "minus")
                                .resizable()
                                .font(.headline)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                                .padding(8)
                                .foregroundColor(Color("color_accent"))
                                .background(Color("color_secondary"))
                                .clipShape(Circle())
                        })
                        .highPriorityGesture(TapGesture().onEnded {
                            decreceProductAmount(cartDetail)
                        })
                        HStack { // Cantidad Producto
                            Text(String(cartDetail.quantity)+" u")
                                .foregroundColor(.black)
                                .font(.custom("Artifika-Regular", size: 16))
                                .padding(.vertical, 2)
                                .padding(.horizontal, 10)
                                .background(Color("color_secondary"))
                                .cornerRadius(20)
                        }
                        Button(action: {}, label: {
                            Image(systemName: "plus")
                                .resizable()
                                .font(.headline)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                                .padding(8)
                                .foregroundColor(Color("color_accent"))
                                .background(Color("color_secondary"))
                                .clipShape(Circle())
                        })
                        .highPriorityGesture(TapGesture().onEnded {
                            increaceProductAmount(cartDetail)
                        })
                        Spacer()
                    }
                }
                .padding(.bottom, 6)
                VStack {
                    HStack(spacing: 0) {
                        Text(String("S/. "))
                            .font(.custom("Artifika-Regular", size: 14))
                        Text(String(cartDetail.product.unitPrice))
                            .font(.custom("Artifika-Regular", size: 16))
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .foregroundColor(.black)
                    .background(Color("color_secondary"))
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

struct CartProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        let cartManager = LocalCartManager(mainContext: CoreDataProvider.shared.viewContext)
        let cartRepository = CarRepositoryImpl(manager: cartManager)
        let cartDetail = CartDetail(id: UUID(), quantity: 24, subtotal: 34, product: Product(id: UUID(uuidString: "3062F3B7-14C7-4314-B342-1EC912EBD925") ?? UUID(), name: "AUDIFONOS C NOISE CANCELLING 1000XM4BMUC", qty: 23, unitCost: 23.4, unitPrice: 12.4, expirationDate: Date(), image: ImageUrl(id: UUID(), imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRenBX4ycM2_FQOz3IYXI1Waln52auoUqqdVQ&usqp=CAU")))
        CartProductCardView(cartDetail: cartDetail, size: 100, decreceProductAmount: {_ in }, increaceProductAmount: {_ in })
            .environmentObject(CartViewModel(carRepository: cartRepository))
    }
}
