//
//  CarritoProductCardView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/04/23.
//

import SwiftUI
import CoreData

struct CarritoProductCardView: View {
    @EnvironmentObject var carritoCoreDataViewModel: CarritoCoreDataViewModel
    let cartDetail: CartDetail
    let size: CGFloat
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                AsyncImage(url: URL(string: cartDetail.product.url )!){ phase in
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
                        Text(cartDetail.product.name)
                            .font(.headline)
                            .fontWeight(.bold) // Alinea el texto a la izquierda
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "minus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 10, height: 10)
                                .padding(12)
                                .foregroundColor(Color("color_accent"))
                                .background(Color("color_secondary"))
                                .clipShape(Circle())
                        }
                        .highPriorityGesture(TapGesture().onEnded {
                            carritoCoreDataViewModel.decreceProductAmount(product: cartDetail.product)
                        })
                        
                        HStack {
                            Text(String("\(cartDetail.quantity) u"))
                                .font(.custom("text_font_1", size: 18))
                        }
                        .padding(.vertical,5)
                        .padding(.horizontal,10)
                        .background(Color("color_secondary"))
                        .cornerRadius(20)
                        
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 10, height: 10)
                                .padding(12)
                                .foregroundColor(Color("color_accent"))
                                .background(Color("color_secondary"))
                                .clipShape(Circle())
                        }
                        .highPriorityGesture(TapGesture().onEnded {
                            carritoCoreDataViewModel.increaceProductAmount(product: cartDetail.product)
                        })
                        Spacer()
                    }
                }
                .padding(.all,5)
                .padding(.trailing,10)
                VStack {
                    HStack {
                        Text(String("S/. "))
                            .font(.custom("text_font_1", size: 15))
                        Text(String(carritoCoreDataViewModel.carritoCoreData?.total ?? 0))
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
            //imageProductNetwork.getImage(url: (URL(string: cartDetail.product.url )!))
        }
    }
}

struct CarritoProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        let cartManager = LocalCarManager(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
        let cartRepository = CarRepositoryImpl(manager: cartManager)
        CarritoProductCardView(cartDetail: CartDetail(id: UUID(), quantity: 0.4, subtotal: 34, product: Product(id: UUID(), name: "Bombones de chocolate Bon O Bon corazón 105", qty: 23, unitCost: 23.4, unitPrice: 12.4, expirationDate: Date(), type: .Kg, url: "https://falabella.scene7.com/is/image/FalabellaPE/19348069_1?wid=180")), size: 100)
            .environmentObject(CarritoCoreDataViewModel(carRepository: cartRepository))
    }
}
