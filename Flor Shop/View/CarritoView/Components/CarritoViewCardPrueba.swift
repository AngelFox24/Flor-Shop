//
//  CarritoViewCardPrueba.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 6/05/23.
//

import SwiftUI

struct CarritoViewCardPrueba: View {
    @ObservedObject var imageProductNetwork = ImageProductNetworkViewModel()
    @State var cantidad:Double = 0.0
    let size: CGFloat
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                if let imageC = imageProductNetwork.imageProduct {
                    imageC
                        .resizable()
                        .frame(width: size,height: size)
                        .cornerRadius(20.0)
                }else {
                    Image("ProductoSinNombre")
                        .resizable()
                        .frame(width: size,height: size)
                        .cornerRadius(20.0)
                }
                VStack {
                    HStack {
                        Text("Sin nombre")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal,5)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "minus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 15, height: 15)
                                .padding(12)
                                .foregroundColor(Color("color_background"))
                                .background(Color("color_secondary"))
                                .clipShape(Circle())
                        }
                        .highPriorityGesture(TapGesture().onEnded {
                            cantidad -= 1
                        })
                        
                        HStack {
                            Text(String(cantidad))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical,10)
                        .padding(.horizontal,10)
                        .foregroundColor(Color("color_background"))
                        .background(Color("color_secondary"))
                        .cornerRadius(20)
                        
                        Button(action: {}){
                            Image(systemName: "plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 15, height: 15)
                                .padding(12)
                                .foregroundColor(Color("color_background"))
                                .background(Color("color_secondary"))
                                .clipShape(Circle())
                        }
                        .highPriorityGesture(TapGesture().onEnded {
                            cantidad += 1
                        })
                        
                        HStack {
                            Text("S/. "+String(23.4 ))
                        }
                        .frame(maxWidth: .infinity)
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
            //imageProductNetwork.getImage(id: UUID(), url: (URL(string: "https://falabella.scene7.com/is/image/FalabellaPE/19038679_1?wid=180")!))
        }
    }
}

struct CarritoViewCardPrueba_Previews: PreviewProvider {
    static var previews: some View {
        CarritoViewCardPrueba(size: 120)
    }
}
