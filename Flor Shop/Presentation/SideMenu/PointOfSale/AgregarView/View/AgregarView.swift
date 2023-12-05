//
//  AgregarView2.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 19/08/23.
//

import SwiftUI

struct AgregarView: View {
    //@State var editedFields = AgregarViewModel()
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                AgregarTopBar()
                CamposProductoAgregar()
            }
            .background(Color("color_background"))
        }
    }
}

struct AgregarView_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        AgregarView()
            .environmentObject(dependencies.agregarViewModel)
    }
}

struct ErrorMessageText: View {
    let message: String
    var body: some View {
        Text(message)
            .foregroundColor(.red)
    }
}

struct CamposProductoAgregar: View {
    @EnvironmentObject var agregarViewModel: AgregarViewModel
    var sizeCampo: CGFloat = 150
    var body: some View {
        //List(content: {
        /*Para formularios no es necesario usar List ya que se tiene:
         - Padding por default
         - Necesita especificar el color de fondo de los elementos de la lista y ocultar el separador
            .listRowBackground(Color("color_background"))
            .listRowSeparator(.hidden)
         - Necesita especificar PlainListStyle
            .listStyle(PlainListStyle())
         */
        ScrollView(content: {
            VStack(spacing: 23, content: {
                HStack {
                    Spacer()
                    AsyncImage(url: URL(string: agregarViewModel.editedFields.imageUrl )) { phase in
                        switch phase {
                        case .empty:
                            CardViewPlaceHolder2(size: sizeCampo)
                        case .success(let returnetImage):
                            returnetImage
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: sizeCampo, height: sizeCampo)
                                .cornerRadius(20.0)
                        case .failure:
                            CardViewPlaceHolder2(text: "Fallo en Carga", size: sizeCampo)
                        default:
                            CardViewPlaceHolder2(text: "Error", size: sizeCampo)
                        }
                    }
                    Spacer()
                }
                VStack {
                    HStack {
                        // El texto hace que tenga una separacion mayor del elemento
                        HStack {
                            CustomTextField(title: "Nombre del Producto" ,value: $agregarViewModel.editedFields.productName, edited: $agregarViewModel.editedFields.productEdited)
                        }
                        Button(action: {
                            print("Se presiono Buscar Imagen")
                            if agregarViewModel.editedFields.productName != "" {
                                openGoogleImageSearch(nombre: agregarViewModel.editedFields.productName)
                            }
                        }, label: {
                            Text("Buscar Imagen")
                                .foregroundColor(.black)
                                .font(.custom("Artifika-Regular", size: 16))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 5)
                                .background(Color("color_secondary"))
                                .cornerRadius(10)
                        })
                    }
                    if agregarViewModel.editedFields.productError != "" {
                        ErrorMessageText(message: agregarViewModel.editedFields.productError)
                            .padding(.top, 6)
                    }
                }
                .listRowBackground(Color("color_background"))
                .listRowSeparator(.hidden)
                VStack {
                    HStack {
                        HStack {
                            HStack {
                                CustomTextField(title: "URL de la Imagen" ,value: $agregarViewModel.editedFields.imageUrl, edited: $agregarViewModel.editedFields.imageURLEdited)
                            }
                            Spacer()
                            Button(action: {
                                print("Se presiono Pegar Imagen")
                                if agregarViewModel.editedFields.productName != "" {
                                    agregarViewModel.editedFields.imageUrl = pasteFromClipboard()
                                } else {
                                    agregarViewModel.urlEdited()
                                }
                            }, label: {
                                Text("Pegar Imagen")
                                    .foregroundColor(.black)
                                    .font(.custom("Artifika-Regular", size: 16))
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 5)
                                    .background(Color("color_secondary"))
                                    .cornerRadius(10)
                            })
                        }
                    }
                    if !agregarViewModel.isURLValid() && agregarViewModel.editedFields.productName != "" && agregarViewModel.editedFields.imageURLEdited {
                        ErrorMessageText(message: "Pega la imagen copiada")
                            .padding(.top, 6)
                    } else if !agregarViewModel.isURLValid() && agregarViewModel.editedFields.imageURLEdited {
                        ErrorMessageText(message: "Ingresa un nombre de producto")
                            .padding(.top, 6)
                    }
                }
                VStack {
                    HStack {
                        CustomTextField(title: "Cantidad" ,value: $agregarViewModel.editedFields.quantityStock, edited: $agregarViewModel.editedFields.quantityEdited, keyboardType: .numberPad)
                        CustomTextField(title: "Costo Unitario" ,value: $agregarViewModel.editedFields.unitCost, edited: $agregarViewModel.editedFields.unitCostEdited, keyboardType: .decimalPad)
                    }
                    if agregarViewModel.editedFields.quantityError != "" {
                        ErrorMessageText(message: agregarViewModel.editedFields.quantityError)
                            .padding(.top, 18)
                    }
                    if agregarViewModel.editedFields.unitCostError != "" {
                        ErrorMessageText(message: agregarViewModel.editedFields.unitCostError)
                            .padding(.top, 6)
                    }
                }
                VStack {
                    HStack {
                        CustomTextField(title: "Margen de Ganancia" ,value: .constant(agregarViewModel.editedFields.profitMargin), edited: .constant(false), disable: true)
                        CustomTextField(title: "Precio de Venta" ,value: $agregarViewModel.editedFields.unitPrice, edited: $agregarViewModel.editedFields.unitPriceEdited, keyboardType: .decimalPad)
                    }
                    if agregarViewModel.editedFields.unitPriceError != "" {
                        ErrorMessageText(message: agregarViewModel.editedFields.unitPriceError)
                            .padding(.top, 6)
                    }
                }
            })
            .padding(.top, 10)
        })
        .padding(.horizontal, 10)
    }
}
