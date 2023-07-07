//
//  CartProductCardView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/04/23.
//

import SwiftUI
import CoreData

struct CartProductCardView: View {
    let cartDetail: CartDetail
    let size: CGFloat
    var decreceProductAmount: (Product) -> Void
    var increaceProductAmount: (Product) -> Void
    @State var sizeX: CGSize = .zero
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                CustomAsyncImageView(id: cartDetail.product.id, urlProducto: cartDetail.product.url , size: size)
                VStack {
                    HStack {
                        Text(cartDetail.product.name)
                            .font(.custom("text_font_1", size: 16))
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .padding(.top, 6)
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "minus")
                                .resizable()
                                .font(.headline)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                                .padding(8)
                                .foregroundColor(Color("color_accent"))
                                .background(Color("color_secondary"))
                                .clipShape(Circle())
                        }
                        .highPriorityGesture(TapGesture().onEnded {
                            decreceProductAmount(cartDetail.product)
                        })
                        HStack { //Cantidad Producto
                            Text(String(format: "%.0f",cartDetail.quantity)+" u")
                                .font(.custom("text_font_1", size: 16))
                                .padding(.vertical,5)
                                .padding(.horizontal,10)
                                .background(Color("color_secondary"))
                                .cornerRadius(20)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .resizable()
                                .font(.headline)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                                .padding(8)
                                .foregroundColor(Color("color_accent"))
                                .background(Color("color_secondary"))
                                .clipShape(Circle())
                        }
                        .highPriorityGesture(TapGesture().onEnded {
                            increaceProductAmount(cartDetail.product)
                        })
                        Spacer()
                    }
                }
                .padding(.bottom,6)
                VStack {
                    HStack(spacing: 0) {
                        Text(String("S/. "))
                            .font(.custom("text_font_1", size: 15))
                        Text(String(cartDetail.product.unitPrice))
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

struct CartProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        let cartManager = LocalCarManager(containerBDFlor: CoreDataProvider.shared.persistContainer)
        let cartRepository = CarRepositoryImpl(manager: cartManager)
        let cartDetail = CartDetail(id: UUID(), quantity: 24.9, subtotal: 34, product: Product(id: UUID(uuidString: "3062F3B7-14C7-4314-B342-1EC912EBD925") ?? UUID(), name: "AUDIFONOS C NOISE CANCELLING 1000XM4BMUC", qty: 23, unitCost: 23.4, unitPrice: 12.4, expirationDate: Date(), type: .Kg, url: "https://falabella.scene7.com/is/image/FalabellaPE/882430431_1?wid=180", replaceImage: false))
        CartProductCardView(cartDetail: cartDetail, size: 100, decreceProductAmount: {_ in }, increaceProductAmount: {_ in })
            .environmentObject(CartViewModel(carRepository: cartRepository))
    }
}
//Sirve para saber el alto y ancho de un objeto
/*
 struct SomeView: View {
     
     @State var sizeX: CGSize = .zero
     
     var body: some View {
         VStack {
             
             Text("hello")
                 .saveSize(in: $sizeX)
         }
        let _ = print ("width: \(sizeX.width) height: \(sizeX.height)")
         
     }
 }
 */
struct SizeCalculator: ViewModifier {
    
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear // we just want the reader to get triggered, so let's use an empty color
                        .onAppear {
                            size = proxy.size
                        }
                }
            )
    }
}

extension View {
    func saveSize(in size: Binding<CGSize>) -> some View {
        modifier(SizeCalculator(size: size))
    }
}
