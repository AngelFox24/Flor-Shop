//
//  CarritoProductCardView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/04/23.
//

import SwiftUI
import CoreData

struct CarritoProductCardView: View {
    @ObservedObject var imageProductNetwork = ImageProductNetworkViewModel()
    @EnvironmentObject var carritoCoreDataViewModel: CarritoCoreDataViewModel
    let detalleCarritoEntity:Tb_DetalleCarrito
    let size: CGFloat
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                imageProductNetwork.imageProduct
                    .resizable()
                    .frame(width: size,height: size)
                    .cornerRadius(20.0)
                VStack {
                    HStack {
                        Text(detalleCarritoEntity.detalleCarrito_to_producto?.nombreProducto ?? "Sin nombre")
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
                            carritoCoreDataViewModel.decreceProductAmount(productoEntity: detalleCarritoEntity.detalleCarrito_to_producto!)
                        })
                        
                        HStack {
                            Text(String(detalleCarritoEntity.cantidad))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical,10)
                        .padding(.horizontal,10)
                        .foregroundColor(Color("color_background"))
                        .background(Color("color_secondary"))
                        .cornerRadius(20)
                        
                        
                        Button(action: {}) {
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
                            carritoCoreDataViewModel.increaceProductAmount(productoEntity: detalleCarritoEntity.detalleCarrito_to_producto!)
                        })
                        
                        HStack {
                            Text("S/. "+String(detalleCarritoEntity.subtotal))
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
            imageProductNetwork.getImage(url: (URL(string: detalleCarritoEntity.detalleCarrito_to_producto?.url ?? "")!))
        }
    }
}
/*
 struct CarritoProductCardView_Previews: PreviewProvider {
 static var previews: some View {
 let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
 CarritoProductCardView(detalleCarritoEntity: Tb_DetalleCarrito(context: context), size: 120)
 .environmentObject(CarritoCoreDataViewModel())
 }
 }
 */
