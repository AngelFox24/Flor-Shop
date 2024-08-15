//
//  AgregarView2.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 19/08/23.
//

import SwiftUI
import PhotosUI

struct AgregarView: View {
    @EnvironmentObject var agregarViewModel: AgregarViewModel
    @FocusState var currentFocusField: AllFocusFields?
    @Binding var selectedTab: Tab
    var body: some View {
//        ZStack {
            VStack(spacing: 0) {
                AgregarTopBar()
                CamposProductoAgregar(agregarFields: agregarViewModel.agregarFields, selectedTab: $selectedTab, currentFocusField: $currentFocusField)
            }
            .background(Color("color_background"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
//        }
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
    @ObservedObject var agregarFields: AgregarFields
    @EnvironmentObject var viewStates: ViewStates
    @Binding var selectedTab: Tab
    var currentFocusField: FocusState<AllFocusFields?>.Binding
    var sizeCampo: CGFloat = 150
    var body: some View {
            HStack(spacing: 0, content: {
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
                                uiImage: $agregarFields.selectedLocalImage,
                                size: sizeCampo,
                                searchFromInternet: searchFromInternet,
                                searchFromGallery: searchFromGallery,
                                takePhoto: takePhoto
                            )
                            .photosPicker(isPresented: $agregarFields.isShowingPicker, selection: $agregarFields.selectionImage, matching: .any(of: [.images, .screenshots]))
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
                            if agregarFields.imageURLError != "" {
                                ErrorMessageText(message: agregarFields.imageURLError)
                                    .padding(.top, 6)
                            }
                        }
                        VStack {
                            HStack {
                                CustomTextField(placeHolder: "", title: "Código de barras" ,value: $agregarFields.scannedCode, edited: .constant(false))
                                Button {
                                    agregarFields.isShowingScanner.toggle()
                                } label: {
                                    Image(systemName: "barcode.viewfinder")
                                        .font(.largeTitle)
                                        .foregroundStyle(Color("color_accent"))
                                        .padding(.horizontal, 5)
                                }
                                .sheet(isPresented: $agregarFields.isShowingScanner, content: {
                                    BarcodeScannerView { code in
                                        self.agregarFields.scannedCode = code
                                        self.agregarFields.isShowingScanner = false
                                    }
                                    .presentationDetents([.height(CGFloat(UIScreen.main.bounds.height / 3))])
                                })
                                
                            }
                        }
                        VStack {
                            HStack {
                                // El texto hace que tenga una separacion mayor del elemento
                                HStack {
                                    CustomTextField(title: "Nombre del Producto" ,value: $agregarFields.productName, edited: $agregarFields.productEdited)
                                        .onChange(of: agregarFields.productName, perform: { newVal in
                                            print("producto en vista: \(agregarFields.productName)")
                                        })
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
                            if agregarFields.productError != "" {
                                ErrorMessageText(message: agregarFields.productError)
                                    .padding(.top, 6)
                            }
                        }
                        VStack {
                            HStack {
                                HStack {
                                    CustomTextField(title: "Disponible" ,value: .constant(agregarFields.active ? "Activo" : "Inactivo"), edited: .constant(false), disable: true)
                                }
                                Toggle("", isOn: $agregarFields.active)
                                    .labelsHidden()
                                    .toggleStyle(SwitchToggleStyle(tint: Color("color_accent")))
                                    .padding(.horizontal, 5)
                            }
                        }
                        VStack {
                            TypeUnitView(value: $agregarFields.unitType)
                                .onChange(of: agregarFields.unitType, perform: { newVal in
                                    print("product in place: \(agregarFields.productName)")
                                })
                        }
                        VStack {
                            HStack {
                                CustomTextField(placeHolder: "0", title: "Cantidad" ,value: $agregarFields.quantityStock, edited: $agregarFields.quantityEdited, keyboardType: .numberPad)
                                CustomNumberField(placeHolder: "0", title: "Costo Unitario" ,userInput: $agregarFields.unitCost, edited: $agregarFields.unitCostEdited)
                            }
                            if agregarFields.quantityError != "" {
                                ErrorMessageText(message: agregarFields.quantityError)
                                    .padding(.top, 18)
                            }
                            if agregarFields.unitCostError != "" {
                                ErrorMessageText(message: agregarFields.unitCostError)
                                    .padding(.top, 6)
                            }
                        }
                        VStack {
                            HStack {
                                CustomTextField(title: "Margen de Ganancia" ,value: .constant(agregarFields.profitMargin), edited: .constant(false), disable: true)
                                CustomNumberField(placeHolder: "0", title: "Precio de Venta", userInput: $agregarFields.unitPrice, edited: $agregarFields.unitPriceEdited)
                            }
                            if agregarFields.unitPriceError != "" {
                                ErrorMessageText(message: agregarFields.unitPriceError)
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
        viewStates.isShowMenu = true
    }
    func goToProductList() {
        selectedTab = .magnifyingglass
    }
    func searchFromInternet() {
        agregarViewModel.findProductNameOnInternet()
    }
    func searchFromGallery() {
        agregarFields.isShowingPicker = true
    }
    func takePhoto() {
        
    }
}
