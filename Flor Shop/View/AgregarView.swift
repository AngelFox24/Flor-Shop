//
//  AgregarView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/04/23.
//

import SwiftUI

struct AgregarView: View {
    let viewName = "AgregarView"
    var body: some View {
        ZStack{
            Color("color_background")
                .ignoresSafeArea()
            CamposProductoAgregar()
            VStack {
                DefaultTopBar(titleBar: "Agregar Producto")
                Spacer()
                BottonBar(vista: viewName)
            }
        }
        .navigationBarHidden(true)
    }
    
}

struct AgregarView_Previews: PreviewProvider {
    static var previews: some View {
        AgregarView()
    }
}

struct CampoIndividual:View {
    @Binding var contenido:String
    var body: some View {
        HStack {
            TextField("", text: $contenido)
                .multilineTextAlignment(.center)
                .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.blue, lineWidth: 2)
                    )
            .foregroundColor(Color("color_primary"))
        }
        .padding(.horizontal,1)
            
    }
}

struct CamposProductoAgregar: View {
    @State private var nombreProducto:String = ""
    @State private var costoTotal:String = ""
    @State private var cantidadProducto:String = ""
    @State private var tipoMedicion:String = "Kilos"
    @State private var urlProducto:String = ""
    @State private var palabrasClave:String = ""
    @State private var fechaVencimiento:String = ""
    @State private var costoUnitario:String = ""
    @State private var margenGanancia:String = ""
    @State private var precioUnitario:String = ""
    var sizeCampo:CGFloat = 200
    var body: some View{
        ScrollView(.vertical,showsIndicators: false) {
            VStack{
                HStack {
                    Image(systemName: "hourglass")
                        .resizable()
                        .frame(width: 100,height: 100)
                    Spacer()
                    VStack{
                        Text("Nombre del Producto")
                            .font(.headline)
                        CampoIndividual(contenido: $nombreProducto)
                    }
                    .frame(width: sizeCampo)
                }
                HStack {
                    Text("Costo Total")
                        .font(.headline)
                    Spacer()
                    CampoIndividual(contenido: $costoTotal)
                        .frame(width: sizeCampo)
                }
                HStack {
                    Text("Cantidad")
                        .font(.headline)
                    Spacer()
                    HStack {
                        CampoIndividual(contenido: $cantidadProducto)
                        Menu {
                            Button(){
                                self.tipoMedicion = "Kilos"
                            } label: {
                                Text("Kilos")
                            }
                            Button(){
                                self.tipoMedicion = "Unidades"
                            } label: {
                                Text("Unidades")
                            }
                        }label: {
                            Text(tipoMedicion)
                                .padding(.horizontal,10)
                        }
                    }
                    .frame(width: sizeCampo)
                }
                HStack {
                    Text("URL")
                        .font(.headline)
                    Spacer()
                    CampoIndividual(contenido: $costoTotal)
                        .frame(width: sizeCampo)
                }
                HStack {
                    Text("Palabras Clave")
                        .font(.headline)
                    Spacer()
                    CampoIndividual(contenido: $costoTotal)
                        .frame(width: sizeCampo)
                }
                HStack {
                    Text("Fecha Vencimiento")
                        .font(.headline)
                    Spacer()
                    CampoIndividual(contenido: $costoTotal)
                        .frame(width: sizeCampo)
                }
                HStack {
                    VStack{
                        Text("Costo Unitario")
                            .font(.headline)
                        Spacer()
                        CampoIndividual(contenido: $costoTotal)
                    }
                    .padding(.vertical,10)
                    VStack{
                        Text("Margen de Ganancia")
                            .font(.headline)
                        Spacer()
                        CampoIndividual(contenido: $costoTotal)
                    }
                    .padding(.vertical,10)
                    VStack{
                        Text("Precio Unitario")
                            .font(.headline)
                        Spacer()
                        CampoIndividual(contenido: $costoTotal)
                    }
                    .padding(.vertical,10)
                }
            }
        }
        .padding(.horizontal,20)
        .padding(.vertical,60)
    }
}
