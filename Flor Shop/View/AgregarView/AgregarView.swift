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
            }
        }
    }
}

struct AgregarView_Previews: PreviewProvider {
    static var previews: some View {
        AgregarView()
            .environmentObject(ProductoCoreDataViewModel())
            .environmentObject(ProductCoreDataViewModel())
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
    @EnvironmentObject var productsCoreDataViewModel: ProductCoreDataViewModel
    @State private var nombreProducto:String = "Chisitos"
    @State private var costoTotal:String = "25.00"
    @State private var cantidadProducto:String = "10"
    @State private var tipoMedicion:String = "Uni"
    @State private var urlProducto:String = "https://falabella.scene7.com/is/image/FalabellaPE/19316385_1?wid=180"
    @State private var palabrasClave:String = "TUR"
    @State private var fechaVencimiento:String = "2023-09-23"
    @State private var costoUnitario:String = "2.00"
    @State private var margenGanancia:String = "0.3"
    @State private var precioUnitario:String = "2.50"
    var sizeCampo:CGFloat = 200
    var body: some View{
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
                            self.tipoMedicion = "Kg"
                        } label: {
                            Text("Kilos")
                        }
                        Button(){
                            self.tipoMedicion = "Uni"
                        } label: {
                            Text("Unidades")
                        }
                    }label: {
                        Text(self.tipoMedicion)
                        //.padding(.horizontal,10)
                        
                    }
                    .buttonStyle(.bordered)
                    .cornerRadius(10)
                }
                .frame(width: sizeCampo)
            }
            HStack {
                Text("URL")
                    .font(.headline)
                Spacer()
                CampoIndividual(contenido: $urlProducto)
                    .frame(width: sizeCampo)
            }
            HStack {
                Text("Palabras Clave")
                    .font(.headline)
                Spacer()
                CampoIndividual(contenido: $palabrasClave)
                    .frame(width: sizeCampo)
            }
            HStack {
                Text("Fecha Vencimiento")
                    .font(.headline)
                Spacer()
                CampoIndividual(contenido: $fechaVencimiento)
                    .frame(width: sizeCampo)
            }
            HStack {
                VStack{
                    Text("Costo Unitario")
                        .font(.headline)
                    CampoIndividual(contenido: $costoUnitario)
                }
                .padding(.vertical,10)
                VStack{
                    Text("Margen de Ganancia")
                        .font(.headline)
                    CampoIndividual(contenido: $margenGanancia)
                }
                .padding(.vertical,10)
                VStack{
                    Text("Precio Unitario")
                        .font(.headline)
                    CampoIndividual(contenido: $precioUnitario)
                }
                .padding(.vertical,10)
            }
            HStack {
                Button(action: {
                    if productsCoreDataViewModel.addProduct(nombre_producto: nombreProducto, cantidad: cantidadProducto, costo_unitario: costoUnitario, precio_unitario: precioUnitario, fecha_vencimiento: fechaVencimiento, tipo: tipoMedicion, url: urlProducto)
                    {
                        nombreProducto = ""
                        costoTotal = ""
                        cantidadProducto = ""
                        tipoMedicion = "Uni"
                        urlProducto = "https://falabella.scene7.com/is/image/FalabellaPE/19316385_1?wid=180"
                        palabrasClave = ""
                        fechaVencimiento = "2023-09-23"
                        costoUnitario = ""
                        margenGanancia = ""
                        precioUnitario = ""
                    }else{
                        
                    }
                    //ProductoCoreDataViewModel.
                }, label:{
                    Text("Guardar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color("color_secondary"))
                        .cornerRadius(20)
                })
                Spacer()
            }
            .padding(.horizontal,20)
            .padding(.vertical,60)
        }
    }
}
