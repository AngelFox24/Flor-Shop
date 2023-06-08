//
//  AgregarView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/04/23.
//

import SwiftUI
import CoreData

struct AgregarView: View {
    var body: some View {
        VStack(spacing: 0){
            AgregarTopBar()
            CamposProductoAgregar()
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
        VStack {
            TextField("", text: $contenido)
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("color_primary"))
        }
        .padding(.all,5)
        .background(Color("color_background"))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color("color_hint"), lineWidth: 2)
        )
    }
}

struct CampoIndividualDouble:View {
    @Binding var contenido:Double
    var body: some View {
        VStack {
            TextField("", value: $contenido, format: .number)
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .foregroundColor(Color("color_primary"))
        }
        .padding(.all,5)
        .background(Color("color_background"))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color("color_hint"), lineWidth: 2)
        )
    }
}

struct CampoIndividualDate:View {
    @Binding var contenido:Date
    var body: some View {
        VStack {
            DatePicker("", selection: $contenido, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .accentColor(Color("color_primary"))
                //.background(Color("color_primary"))
        }
    }
}

struct CampoIndividualDate2:View {
    @Binding var contenido:Date
    var body: some View {
        VStack {
            DatePicker("", selection: $contenido, displayedComponents: .date)
                .font(.system(size: 60))
                .accentColor(Color("color_primary"))
                .datePickerStyle(.compact)
                .labelsHidden()
                .blendMode(/*@START_MENU_TOKEN@*/.hardLight/*@END_MENU_TOKEN@*/)
                .frame(maxWidth: .infinity)
                .foregroundColor(/*@START_MENU_TOKEN@*/.purple/*@END_MENU_TOKEN@*/)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color("color_hint"), lineWidth: 2)
        )
    }
}

struct CamposProductoAgregar: View {
    @EnvironmentObject var productsCoreDataViewModel: ProductCoreDataViewModel
    var sizeCampo:CGFloat = 200
    var body: some View{
        List{
            HStack {
                Spacer()
                /*Image("ProductoSinNombre")
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color("color_hint"), lineWidth: 2)
                    )
                 */
                AsyncImage(url: URL(string: productsCoreDataViewModel.temporalProduct.url )){ phase in
                    switch phase {
                    case .empty:
                        Image("ProductoSinNombre")
                            .resizable()
                            .frame(width: sizeCampo,height: sizeCampo)
                            .cornerRadius(20.0)
                    case .success(let returnetImage):
                        returnetImage
                            .resizable()
                            .frame(width: sizeCampo,height: sizeCampo)
                            .cornerRadius(20.0)
                    case .failure:
                        Image("ProductoSinNombre")
                            .resizable()
                            .frame(width: sizeCampo,height: sizeCampo)
                            .cornerRadius(20.0)
                    default:
                        Image("ProductoSinNombre")
                            .resizable()
                            .frame(width: sizeCampo,height: sizeCampo)
                            .cornerRadius(20.0)
                    }
                }
                Spacer()
                VStack{
                    Text("Nombre del Producto")
                        .font(.headline)
                    CampoIndividual(contenido: $productsCoreDataViewModel.temporalProduct.name)
                }
                .frame(width: sizeCampo)
            }
            .listRowSeparator(.hidden)
            HStack {
                Text("Costo Total")
                    .font(.headline)
                Spacer()
                CampoIndividualDouble(contenido: $productsCoreDataViewModel.temporalProduct.totalCost)
                    .frame(width: sizeCampo)
            }
            .listRowSeparator(.hidden)
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
                            .padding(.vertical,7)
                    }
                    .padding(.horizontal,10)
                    .background(Color("color_hint"))
                    .cornerRadius(10)
                }
                .frame(width: sizeCampo)
            }
            .listRowSeparator(.hidden)
            HStack {
                Text("Imagen URL")
                    .font(.headline)
                Spacer()
                CampoIndividual(contenido: $productsCoreDataViewModel.temporalProduct.url)
                    .frame(width: sizeCampo)
            }
            .listRowSeparator(.hidden)
            HStack {
                Text("Palabras Clave")
                    .font(.headline)
                Spacer()
                CampoIndividual(contenido: $productsCoreDataViewModel.temporalProduct.keyWords)
                    .frame(width: sizeCampo)
            }
            .listRowSeparator(.hidden)
            HStack {
                Text("Fecha Vencimiento")
                    .font(.headline)
                Spacer()
                CampoIndividualDate(contenido: $productsCoreDataViewModel.temporalProduct.expirationDate)
                    .frame(width: sizeCampo)
            }
            .listRowSeparator(.hidden)
            VStack {
                HStack{
                    Spacer()
                    Text("Costo Unitario")
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .padding(.horizontal,5)
                    Spacer()
                    Text("Margen de Ganancia")
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .padding(.horizontal,5)
                    Spacer()
                    Text("Precio Unitario")
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .padding(.horizontal,5)
                    Spacer()
                }
                .padding(.top,15)
                HStack{
                    CampoIndividualDouble(contenido: $productsCoreDataViewModel.temporalProduct.unitCost)
                    CampoIndividualDouble(contenido: $productsCoreDataViewModel.temporalProduct.profitMargin)
                    CampoIndividualDouble(contenido: $productsCoreDataViewModel.temporalProduct.unitPrice)
                }
                .padding(.bottom,10)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(PlainListStyle())
    }
}
