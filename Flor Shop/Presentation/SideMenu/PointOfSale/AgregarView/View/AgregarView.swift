//
//  AgregarView2.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 19/08/23.
//

import SwiftUI

struct AgregarView: View {
    @EnvironmentObject var loadingState: LoadingState
    @EnvironmentObject var agregarViewModel: AgregarViewModel
    @Binding var selectedTab: Tab
    @Binding var showMenu: Bool
    var body: some View {
        ZStack(content: {
            VStack(spacing: 0) {
                AgregarTopBar(showMenu: $showMenu)
                CamposProductoAgregar(showMenu: $showMenu, selectedTab: $selectedTab, isPresented: $agregarViewModel.agregarFields.isPresented)
            }
            .background(Color("color_background"))
            .blur(radius: agregarViewModel.agregarFields.isPresented ? 2 : 0)
            if agregarViewModel.agregarFields.isPresented {
                SourceSelecctionView(isPresented: $agregarViewModel.agregarFields.isPresented, fromInternetAction: agregarViewModel.findProductNameOnInternet, selectionImage: $agregarViewModel.agregarFields.selectionImage)
            }
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct AgregarView_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        AgregarView(selectedTab: .constant(.plus), showMenu: .constant(false))
            .environmentObject(dependencies.agregarViewModel)
            .environmentObject(dependencies.loadingState)
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
    @Binding var showMenu: Bool
    @Binding var selectedTab: Tab
    @Binding var isPresented: Bool
    @State var tipeUnitMes: Bool = true
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
        HStack(spacing: 0, content: {
            SideSwipeView(swipeDirection: .right, swipeAction: goToSideMenu)
            ScrollView(.vertical, showsIndicators: false, content: {
                VStack(spacing: 23, content: {
                    HStack {
                        AgregarViewPopoverHelp()
                            .disabled(true)
                            .opacity(0)
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
                        VStack(spacing: 0) {
                            AgregarViewPopoverHelp()
                            Spacer()
                        }
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
                        TypeUnitView(value: $agregarViewModel.agregarFields.unitType)
                    }
                    VStack {
                        HStack {
                            CustomTextField(placeHolder: "0", title: "Cantidad" ,value: $agregarViewModel.agregarFields.quantityStock, edited: $agregarViewModel.agregarFields.quantityEdited, keyboardType: .numberPad)
                            CustomNumberField(placeHolder: "0", title: "Costo Unitario" ,userInput: $agregarViewModel.agregarFields.unitCost, edited: $agregarViewModel.agregarFields.unitCostEdited)
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
                            CustomNumberField(placeHolder: "0", title: "Precio de Venta", userInput: $agregarViewModel.agregarFields.unitPrice, edited: $agregarViewModel.agregarFields.unitPriceEdited)
                        }
                        if agregarViewModel.agregarFields.unitPriceError != "" {
                            ErrorMessageText(message: agregarViewModel.agregarFields.unitPriceError)
                                .padding(.top, 6)
                        }
                    }
                })
                .padding(.top, 10)
            })
            SideSwipeView(swipeDirection: .left, swipeAction: goToProductList)
        })
    }
    func goToSideMenu() {
        showMenu = true
    }
    func goToProductList() {
        selectedTab = .magnifyingglass
    }
}
