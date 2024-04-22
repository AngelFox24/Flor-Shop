//
//  AgregarView2.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 19/08/23.
//

import SwiftUI

struct AgregarView: View {
    @EnvironmentObject var agregarViewModel: AgregarViewModel
    @Binding var showMenu: Bool
    var body: some View {
        ZStack(content: {
            VStack(spacing: 0) {
                AgregarTopBar(showMenu: $showMenu)
                CamposProductoAgregar(isPresented: $agregarViewModel.agregarFields.isPresented)
            }
            .background(Color("color_background"))
            .blur(radius: agregarViewModel.agregarFields.isPresented ? 2 : 0)
            if agregarViewModel.agregarFields.isPresented {
                SourceSelecctionView(isPresented: $agregarViewModel.agregarFields.isPresented, fromInternetAction: agregarViewModel.findProductNameOnInternet, selectionImage: $agregarViewModel.agregarFields.selectionImage)
            }
            if agregarViewModel.agregarFields.isLoading {
                LoadingView()
            }
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct AgregarView_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        AgregarView(showMenu: .constant(false))
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
    @Binding var isPresented: Bool
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
                    Button(action: {
                        withAnimation(.easeIn) {
                            isPresented = true
                        }
                    }, label: {
                        if let imageC = agregarViewModel.agregarFields.selectedLocalImage {
                            Image(uiImage: imageC)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: sizeCampo, height: sizeCampo)
                                .cornerRadius(15.0)
                        } else {
                            AsyncImage(url: URL(string: agregarViewModel.agregarFields.imageUrl )) { phase in
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
                        }
                    })
                    Spacer()
                }
                VStack {
                    HStack {
                        HStack {
                            Button(action: {
                                agregarViewModel.pasteFromInternet()
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
                    if agregarViewModel.agregarFields.imageURLError != "" {
                        ErrorMessageText(message: agregarViewModel.agregarFields.imageURLError)
                            .padding(.top, 6)
                    }
                }
                VStack {
                    HStack {
                        // El texto hace que tenga una separacion mayor del elemento
                        HStack {
                            CustomTextField(title: "Nombre del Producto" ,value: $agregarViewModel.agregarFields.productName, edited: $agregarViewModel.agregarFields.productEdited)
                        }
                        Button(action: {
                            print("Se presiono Buscar Imagen")
                                agregarViewModel.findProductNameOnInternet()
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
                    if agregarViewModel.agregarFields.productError != "" {
                        ErrorMessageText(message: agregarViewModel.agregarFields.productError)
                            .padding(.top, 6)
                    }
                }
                VStack {
                    HStack {
                        HStack {
                            CustomTextField(title: "Disponible" ,value: .constant(agregarViewModel.agregarFields.active ? "Activo" : "Inactivo"), edited: .constant(false), disable: true)
                        }
                        Toggle("", isOn: $agregarViewModel.agregarFields.active)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: Color("color_accent")))
                            .padding(.horizontal, 5)
                    }
                }
                VStack {
                    HStack {
                        CustomTextField(placeHolder: "0", title: "Cantidad" ,value: $agregarViewModel.agregarFields.quantityStock, edited: $agregarViewModel.agregarFields.quantityEdited, keyboardType: .numberPad)
                        CustomTextField(placeHolder: "0", title: "Costo Unitario" ,value: $agregarViewModel.agregarFields.unitCost, edited: $agregarViewModel.agregarFields.unitCostEdited, keyboardType: .decimalPad)
                    }
                    if agregarViewModel.agregarFields.quantityError != "" {
                        ErrorMessageText(message: agregarViewModel.agregarFields.quantityError)
                            .padding(.top, 18)
                    }
                    if agregarViewModel.agregarFields.unitCostError != "" {
                        ErrorMessageText(message: agregarViewModel.agregarFields.unitCostError)
                            .padding(.top, 6)
                    }
                }
                VStack {
                    HStack {
                        CustomTextField(title: "Margen de Ganancia" ,value: .constant(agregarViewModel.agregarFields.profitMargin), edited: .constant(false), disable: true)
                        CustomTextField(placeHolder: "0", title: "Precio de Venta" ,value: $agregarViewModel.agregarFields.unitPrice, edited: $agregarViewModel.agregarFields.unitPriceEdited, keyboardType: .decimalPad)
                    }
                    if agregarViewModel.agregarFields.unitPriceError != "" {
                        ErrorMessageText(message: agregarViewModel.agregarFields.unitPriceError)
                            .padding(.top, 6)
                    }
                }
            })
            .padding(.top, 10)
        })
        .padding(.horizontal, 10)
    }
}
