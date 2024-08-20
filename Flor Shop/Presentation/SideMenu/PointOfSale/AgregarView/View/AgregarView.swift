//
//  AgregarView2.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 19/08/23.
//

import SwiftUI
import PhotosUI

struct AgregarView: View {
    @Binding var selectedTab: Tab
    var body: some View {
        VStack(spacing: 0) {
            AgregarTopBar()
            CamposProductoAgregar(selectedTab: $selectedTab)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct AgregarView_Previews: PreviewProvider {
    static var previews: some View {
        let nor = NormalDependencies()
        let sesConfig = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: sesConfig)
        AgregarView(selectedTab: .constant(.plus))
            .environmentObject(dependencies.agregarViewModel)
            .environmentObject(nor.viewStates)
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
    @EnvironmentObject var viewStates: ViewStates
    @Binding var selectedTab: Tab
    var sizeCampo: CGFloat = 150
    var body: some View {
        HStack(spacing: 0) {
            SideSwipeView(swipeDirection: .right, swipeAction: goToSideMenu)
            ScrollView(.vertical,
                       showsIndicators: false,
                       content: {
                VStack(spacing: 23,
                       content: {
                    HStack {
                        AgregarViewPopoverHelp()
                            .disabled(true)
                            .opacity(0)
                        Spacer()
                        CustomImageView(
                            uiImage: $agregarViewModel.selectedLocalImage,
                            size: sizeCampo,
                            searchFromInternet: searchFromInternet,
                            searchFromGallery: searchFromGallery,
                            takePhoto: takePhoto
                        )
                        .photosPicker(isPresented: $agregarViewModel.agregarFields.isShowingPicker, selection: $agregarViewModel.selectionImage, matching: .any(of: [.images, .screenshots]))
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
                            CustomTextField(placeHolder: "", title: "Código de barras" ,value: $agregarViewModel.agregarFields.scannedCode, edited: .constant(false))
                            Button {
                                agregarViewModel.agregarFields.isShowingScanner.toggle()
                            } label: {
                                Image(systemName: "barcode.viewfinder")
                                    .font(.largeTitle)
                                    .foregroundStyle(Color("color_accent"))
                                    .padding(.horizontal, 5)
                            }
                            .sheet(isPresented: $agregarViewModel.agregarFields.isShowingScanner, content: {
                                BarcodeScannerView { code in
                                    agregarViewModel.agregarFields.scannedCode = code
                                    agregarViewModel.agregarFields.isShowingScanner = false
                                }
                                .presentationDetents([.height(CGFloat(UIScreen.main.bounds.height / 3))])
                            })
                            
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
        }
        .background(Color("color_background"))
    }
    func goToSideMenu() {
        viewStates.isShowMenu = true
    }
    func goToProductList() {
        selectedTab = .magnifyingglass
    }
    func searchFromInternet() {
        agregarViewModel.findProductNameOnInternet()
    }
    func searchFromGallery() {
        agregarViewModel.agregarFields.isShowingPicker = true
    }
    func takePhoto() {
        
    }
}
