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
                    AsyncImage(url: URL(string: agregarViewModel.imageUrl )) { phase in
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
                        HStack {
                            Button(action: {
                                if agregarViewModel.productName != "" {
                                    agregarViewModel.imageUrl = pasteFromClipboard()
                                    print("Se pego imagen: \(agregarViewModel.imageUrl.description)")
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
                    if agregarViewModel.imageURLError != "" {
                        ErrorMessageText(message: agregarViewModel.imageURLError)
                            .padding(.top, 6)
                    } else if agregarViewModel.productName != "" && agregarViewModel.imageURLEdited {
                        ErrorMessageText(message: "Pega la imagen copiada")
                            .padding(.top, 6)
                    } else if agregarViewModel.imageURLEdited {
                        ErrorMessageText(message: "Ingresa un nombre de producto")
                            .padding(.top, 6)
                    }
                }
                VStack {
                    HStack {
                        // El texto hace que tenga una separacion mayor del elemento
                        HStack {
                            CustomTextField(title: "Nombre del Producto" ,value: $agregarViewModel.productName, edited: $agregarViewModel.productEdited)
                        }
                        Button(action: {
                            print("Se presiono Buscar Imagen")
                            if agregarViewModel.productName != "" {
                                openGoogleImageSearch(nombre: agregarViewModel.productName)
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
                    if agregarViewModel.productError != "" {
                        ErrorMessageText(message: agregarViewModel.productError)
                            .padding(.top, 6)
                    }
                }
                VStack {
                    HStack {
                        HStack {
                            CustomTextField(title: "Disponible" ,value: .constant(agregarViewModel.active ? "Activo" : "Inactivo"), edited: .constant(false), disable: true)
                        }
                        Toggle("", isOn: $agregarViewModel.active)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: Color("color_accent")))
                            .padding(.horizontal, 5)
                    }
                }
                VStack {
                    HStack {
                        CustomTextField(title: "Cantidad" ,value: $agregarViewModel.quantityStock, edited: $agregarViewModel.quantityEdited, keyboardType: .numberPad)
                        CustomTextField(title: "Costo Unitario" ,value: $agregarViewModel.unitCost, edited: $agregarViewModel.unitCostEdited, keyboardType: .decimalPad)
                    }
                    if agregarViewModel.quantityError != "" {
                        ErrorMessageText(message: agregarViewModel.quantityError)
                            .padding(.top, 18)
                    }
                    if agregarViewModel.unitCostError != "" {
                        ErrorMessageText(message: agregarViewModel.unitCostError)
                            .padding(.top, 6)
                    }
                }
                VStack {
                    HStack {
                        CustomTextField(title: "Margen de Ganancia" ,value: .constant(agregarViewModel.profitMargin), edited: .constant(false), disable: true)
                        CustomTextField(title: "Precio de Venta" ,value: $agregarViewModel.unitPrice, edited: $agregarViewModel.unitPriceEdited, keyboardType: .decimalPad)
                    }
                    if agregarViewModel.unitPriceError != "" {
                        ErrorMessageText(message: agregarViewModel.unitPriceError)
                            .padding(.top, 6)
                    }
                }
            })
            .padding(.top, 10)
        })
        .padding(.horizontal, 10)
    }
}
