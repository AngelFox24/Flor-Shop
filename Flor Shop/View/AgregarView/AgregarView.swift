//
//  AgregarView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/04/23.
//

import SwiftUI
import CoreData

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
        let prdManager = LocalProductManager(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
        let repository = ProductRepositoryImpl(manager: prdManager)
        AgregarView()
            .environmentObject(ProductCoreDataViewModel(productRepository: repository))
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
                            .stroke(Color("color_hint"), lineWidth: 2)
                    )
            .foregroundColor(Color("color_primary"))
        }
        .padding(.horizontal,1)
    }
}

struct CampoIndividualDouble:View {
    @Binding var contenido:Double
    var body: some View {
        HStack {
            TextField("", value: $contenido, format: .number)
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color("color_hint"), lineWidth: 2)
                    )
            .foregroundColor(Color("color_primary"))
        }
        .padding(.horizontal,1)
    }
}

struct CampoIndividualDate:View {
    @Binding var contenido:Date
    var body: some View {
        HStack {
            DatePicker("", selection: $contenido, displayedComponents: .date)
                            .datePickerStyle(.compact)
            .foregroundColor(Color("color_primary"))
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal,1)
    }
}

struct CamposProductoAgregar: View {
    @EnvironmentObject var productsCoreDataViewModel: ProductCoreDataViewModel
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
                    CampoIndividual(contenido: $productsCoreDataViewModel.temporalProduct.name)
                }
                .frame(width: sizeCampo)
            }
            HStack {
                Text("Costo Total")
                    .font(.headline)
                Spacer()
                CampoIndividualDouble(contenido: $productsCoreDataViewModel.temporalProduct.totalCost)
                    .frame(width: sizeCampo)
            }
            HStack {
                Text("Cantidad")
                    .font(.headline)
                Spacer()
                HStack {
                    CampoIndividualDouble(contenido: $productsCoreDataViewModel.temporalProduct.qty)
                    Menu {
                        Button(){
                            productsCoreDataViewModel.temporalProduct.type = .Kg
                        } label: {
                            Text("Kilos")
                        }
                        Button(){
                            productsCoreDataViewModel.temporalProduct.type = .Uni
                        } label: {
                            Text("Unidades")
                        }
                    }label: {
                        Text(productsCoreDataViewModel.temporalProduct.type.description)
                    }
                    //.buttonStyle(.bordered)
                    .padding(.horizontal,10)
                    .padding(.vertical,2)
                    .background(Color("color_hint"))
                    .cornerRadius(10)
                }
                .frame(width: sizeCampo)
            }
            HStack {
                Text("Imagen URL")
                    .font(.headline)
                Spacer()
                CampoIndividual(contenido: $productsCoreDataViewModel.temporalProduct.url)
                    .frame(width: sizeCampo)
            }
            HStack {
                Text("Palabras Clave")
                    .font(.headline)
                Spacer()
                CampoIndividual(contenido: $productsCoreDataViewModel.temporalProduct.keyWords)
                    .frame(width: sizeCampo)
            }
            HStack {
                Text("Fecha Vencimiento")
                    .font(.headline)
                Spacer()
                CampoIndividualDate(contenido: $productsCoreDataViewModel.temporalProduct.expirationDate)
                    .frame(width: sizeCampo)
            }
            HStack {
                VStack{
                    Text("Costo Unitario")
                        .font(.headline)
                    CampoIndividualDouble(contenido: $productsCoreDataViewModel.temporalProduct.unitCost)
                }
                .padding(.vertical,10)
                VStack{
                    Text("Margen de Ganancia")
                        .font(.headline)
                    CampoIndividualDouble(contenido: $productsCoreDataViewModel.temporalProduct.profitMargin)
                }
                .padding(.vertical,10)
                VStack{
                    Text("Precio Unitario")
                        .font(.headline)
                    CampoIndividualDouble(contenido: $productsCoreDataViewModel.temporalProduct.unitPrice)
                }
                .padding(.vertical,10)
            }
            HStack {
                HStack {
                    Button(action: {
                        productsCoreDataViewModel.setDefaultProduct()
                    }, label:{
                        Text("Limpiar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color("color_hint"))
                            .cornerRadius(20)
                    })
                }
                .padding(.leading,20)
                .padding(.trailing,10)
                HStack {
                    Button(action: {
                        if productsCoreDataViewModel.addProduct()
                        {
                            print ("Se agrego un producto exitosamente")
                        }
                    }, label:{
                        Text("Guardar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color("color_secondary"))
                            .cornerRadius(20)
                    })
                }
                .padding(.trailing,20)
                .padding(.leading,10)
            }
            .padding(.vertical,50)
        }
        .padding(.horizontal,10)
    }
}
