//
//  PopoverHelp.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 1/08/23.
//

import SwiftUI

struct AgregarViewPopoverHelp: View {
    @State private var isPopoverPresented = false
    var body: some View {
        VStack {
            Button(action: {
                isPopoverPresented.toggle()
            }, label: {
                CustomButton3(simbol: "questionmark")
            })
            .sheet(isPresented: $isPopoverPresented) {
                VStack(spacing: 0) {
                    Text("Cantidad")
                        .font(.custom("Artifika-Regular", size: 18))
                        .padding(.vertical, 15)
                        .foregroundColor(Color.black)
                    Text("Es la cantidad de productos unitarios que vas a agregar a tu tienda, por ejemplo '15' barras de KitKat.")
                        .font(.custom("Artifika-Regular", size: 16))
                        .foregroundColor(Color.black)
                    Text("Costo Unitario")
                        .font(.custom("Artifika-Regular", size: 18))
                        .padding(.vertical, 15)
                        .foregroundColor(Color.black)
                    Text("Es lo que te costo adquirir ese producto por unidad, siempre debe ser menor a Precio de Venta de lo contrario perderias dinero.")
                        .font(.custom("Artifika-Regular", size: 16))
                        .foregroundColor(Color.black)
                    Text("Margen de Ganancia")
                        .font(.custom("Artifika-Regular", size: 18))
                        .padding(.vertical, 15)
                        .foregroundColor(Color.black)
                    Text("Es el porcentaje de ganancia, cuando pongas un Precio de Venta debes fijarte cuanto porcentaje de ganancia tienes, lo recomendable es alrededor de 35%.")
                        .font(.custom("Artifika-Regular", size: 16))
                        .foregroundColor(Color.black)
                    Text("Precio de Venta")
                        .font(.custom("Artifika-Regular", size: 18))
                        .padding(.vertical, 15)
                        .foregroundColor(Color.black)
                    Text("Es el precio al publico en general, los clientes pagan este precio por cada producto unitario, siempre debe ser mayor a Costo Unitario de lo contrario perderias dinero.")
                        .font(.custom("Artifika-Regular", size: 16))
                        .foregroundColor(Color.black)
                    Button(action: {
                        isPopoverPresented.toggle()
                    }, label: {
                        CustomButton1(text: "Cerrar")
                    })
                    .padding(.top, 20)
                    Spacer()
                }
                .background(Color("color_background"))
            }
        }
    }
}

struct AgregarViewPopoverHelp_Previews: PreviewProvider {
    static var previews: some View {
        AgregarViewPopoverHelp()
    }
}
