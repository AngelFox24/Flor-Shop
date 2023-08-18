//
//  AgregarView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/04/23.
//

import SwiftUI
import CoreData
import UniformTypeIdentifiers
import SafariServices

struct AgregarView: View {
    //@State var editedFields = AgregarViewModel()
    @State var buttonPress = false
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                AgregarTopBar(buttonPress: $buttonPress)
                CamposProductoAgregar(buttonPress: $buttonPress)
            }
            .background(Color("color_background"))
        }
    }
}

struct AgregarView_Previews: PreviewProvider {
    static var previews: some View {
        let prdManager = LocalProductManager(mainContext: CoreDataProvider.shared.viewContext)
        let repository = ProductRepositoryImpl(manager: prdManager)
        AgregarView()
           .environmentObject(ProductViewModel(productRepository: repository))
           .environmentObject(AgregarViewModel(productRepository: repository))
            //.ignoresSafeArea()
    }
}

struct CampoIndividual: View {
    @Binding var contenido: String
    @Binding var edited: Bool
    var body: some View {
        VStack {
            TextField("Nombre del Producto", text: $contenido)
                .foregroundColor(.black)
                .font(.custom("Artifika-Regular", size: 18))
                .multilineTextAlignment(.center)
                .submitLabel(.search)
                .onTapGesture {
                    withAnimation {
                        contenido.removeAll()
                        edited = true
                    }
                }
                .onSubmit({
                    if contenido != "" {
                        openGoogleImageSearch(nombre: contenido)
                    }
                })
        }
        .padding(.all, 5)
        .background(.white)
        .cornerRadius(15)
    }
}

struct CampoIndividualURL: View {
    @Binding var contenido: String
    @Binding var edited: Bool
    var body: some View {
        VStack {
            TextField("Pega la imagen", text: $contenido)
                .foregroundColor(.black)
                .font(.custom("Artifika-Regular", size: 18))
                .multilineTextAlignment(.center)
                .onTapGesture {
                    withAnimation {
                        contenido.removeAll()
                        edited = true
                    }
                }
        }
        .padding(.all, 5)
        .background(.white)
        .cornerRadius(15)
    }
}

struct CampoIndividualDoubleLocked: View {
    var contenido: Double
    var body: some View {
        VStack {
            Text(String(format: "%.0f", (contenido * 100).rounded())+" %")
                .font(.custom("Artifika-Regular", size: 18))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .disabled(true)
                .frame(maxWidth: .infinity)
        }
        .padding(.all, 5)
        .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.884))
        .cornerRadius(15)
    }
}

struct CampoIndividualDouble: View {
    @Binding var contenido: Double
    @State var value: String = "0"
    @State private var oldValue: String = ""
    @FocusState var focus: Bool
    @Binding var edited: Bool
    var action: () -> Void
    var disableInput: Bool = false
    var body: some View {
        VStack {
            TextField("", text: $value)
                .foregroundColor(.black)
                .font(.custom("Artifika-Regular", size: 18))
                .disabled(disableInput)
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .focused($focus)
                .onTapGesture {
                    withAnimation {
                        contenido = 0
                        edited = true
                    }
                }
                .onChange(of: focus, perform: { editing in
                    if editing {
                        if !value.isEmpty {
                            oldValue = value
                            value = ""
                        }
                    } else {
                        if value.isEmpty {
                            value = oldValue
                        } else {
                            if let valueDouble: Double = Double(value) {
                                contenido = valueDouble
                            } else {
                                value = oldValue
                            }
                        }
                    }
                    action()
                })
                .onChange(of: value, perform: { _ in
                    action()
                    if let valueDouble: Double = Double(value) {
                        contenido = valueDouble
                    }
                })
                .onChange(of: contenido, perform: { _ in
                    if edited == false {
                        value = String(contenido)
                    }
                })
                .onAppear(perform: {
                    value = String(contenido)
                })
        }
        .padding(.all, 5)
        .background(.white)
        .cornerRadius(15)
    }
}

struct CampoIndividualInt: View {
    @Binding var contenido: Int
    @State var value: String = "0"
    @State private var oldValue: String = ""
    @FocusState var focus: Bool
    @Binding var edited: Bool
    var body: some View {
        VStack {
            TextField("", text: $value)
                .foregroundColor(.black)
                .font(.custom("Artifika-Regular", size: 18))
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .focused($focus)
                .onTapGesture {
                    withAnimation {
                        contenido = 0
                        edited = true
                    }
                }
                .onChange(of: focus, perform: { editing in
                    if editing {
                        if !value.isEmpty {
                            oldValue = value
                            value = ""
                        }
                    } else {
                        if value.isEmpty {
                            value = oldValue
                        } else {
                            if let valueDouble: Int = Int(value) {
                                contenido = valueDouble
                            } else {
                                value = oldValue
                            }
                        }
                    }
                })
                .onChange(of: value, perform: { _ in
                    if let valueDouble: Int = Int(value) {
                        contenido = valueDouble
                    }
                })
                .onChange(of: contenido, perform: { _ in
                    if edited == false {
                        value = String(contenido)
                    }
                })
                .onAppear(perform: {
                    value = String(contenido)
                })
        }
        .padding(.all, 5)
        .background(.white)
        .cornerRadius(15)
    }
}

struct CampoIndividualDate: View {
    @Binding var contenido: Date
    var body: some View {
        VStack {
            DatePicker("", selection: $contenido, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .accentColor(Color("color_primary"))
        }
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
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    @EnvironmentObject var agregarViewModel: AgregarViewModel
    @Binding var buttonPress: Bool
    var sizeCampo: CGFloat = 200
    var body: some View {
        List {
            HStack {
                Spacer()
                AsyncImage(url: URL(string: productsCoreDataViewModel.temporalProduct.url )) { phase in
                    switch phase {
                    case .empty:
                        Image("ProductoSinNombre")
                            .resizable()
                            .frame(width: sizeCampo, height: sizeCampo)
                            .cornerRadius(20.0)
                    case .success(let returnetImage):
                        returnetImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: sizeCampo, height: sizeCampo)
                            .cornerRadius(20.0)
                    case .failure:
                        Image("groundhog-cry")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: sizeCampo, height: sizeCampo)
                            .cornerRadius(20.0)
                    default:
                        Image("groundhog-cry")
                            .resizable()
                            .frame(width: sizeCampo, height: sizeCampo)
                            .cornerRadius(20.0)
                    }
                }
                Spacer()
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color("color_background"))
            // El costo total se ultizara en el futuro
            /*
            HStack {
                Text("Costo Total")
                    .font(.headline)
                Spacer()
                CampoIndividualDouble(contenido: $productsCoreDataViewModel.temporalProduct.totalCost)
                    .frame(width: sizeCampo)
            }
            .listRowBackground(Color("color_background"))
            .listRowSeparator(.hidden)
            */
            VStack {
                HStack {
                    // El texto hace que tenga una separacion mayor del elemento
                        HStack {
                            /*
                            Text("Nombre")
                                .font(.headline)
                                .frame(width: geometry.size.width / 5)
                                .foregroundColor(.black)
                            Spacer()
                            */
                            HStack {
                                CampoIndividual(contenido: $productsCoreDataViewModel.temporalProduct.name, edited: $agregarViewModel.editedFields.productEdited)
                            }
                            Button(action: {
                                if productsCoreDataViewModel.temporalProduct.name != "" {
                                    openGoogleImageSearch(nombre: productsCoreDataViewModel.temporalProduct.name)
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
                }
                if !productsCoreDataViewModel.temporalProduct.isProductNameValid() && agregarViewModel.editedFields.productEdited {
                    ErrorMessageText(message: "Nombre no válido")
                        .padding(.top, 6)
                }
            }
            .listRowBackground(Color("color_background"))
            .listRowSeparator(.hidden)
            VStack {
                HStack {
                    HStack {
                        HStack {
                            CampoIndividualURL(contenido: $productsCoreDataViewModel.temporalProduct.url, edited: $agregarViewModel.editedFields.imageURLEdited)
                        }
                        Spacer()
                        Button(action: {
                            if productsCoreDataViewModel.temporalProduct.name != "" {
                                productsCoreDataViewModel.temporalProduct.url = pasteFromClipboard()
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
                if !productsCoreDataViewModel.temporalProduct.isURLValid() && productsCoreDataViewModel.temporalProduct.name != "" && agregarViewModel.editedFields.imageURLEdited {
                    ErrorMessageText(message: "Pega la imagen copiada")
                        .padding(.top, 6)
                } else if !productsCoreDataViewModel.temporalProduct.isURLValid() && agregarViewModel.editedFields.imageURLEdited {
                    ErrorMessageText(message: "Ingresa un nombre de producto")
                        .padding(.top, 6)
                }
            }
            .listRowBackground(Color("color_background"))
            .listRowSeparator(.hidden)
            VStack {
                GeometryReader { geometry in
                    HStack {
                        Text("Cantidad")
                            .font(.custom("Artifika-Regular", size: 18))
                            .frame(width: geometry.size.width / 3)
                            .foregroundColor(.black)
                        Spacer()
                        HStack {
                            CampoIndividualInt(contenido: $productsCoreDataViewModel.temporalProduct.qty, edited: $agregarViewModel.editedFields.quantityEdited)
                            /*
                            Menu {
                                /*
                                Button(){
                                    productsCoreDataViewModel.temporalProduct.type = .Kg
                                } label: {
                                    Text("Kilos")
                                }
                                 */
                                Button {
                                    productsCoreDataViewModel.temporalProduct.type = .uni
                                } label: {
                                    Text("Unidades")
                                }
                            }label: {
                                Text(productsCoreDataViewModel.temporalProduct.type.description)
                                    .padding(.vertical, 7)
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 10)
                            .background(Color("color_secondary"))
                            .cornerRadius(10)
                            */
                        }
                    }
                }
                if !productsCoreDataViewModel.temporalProduct.isQuantityValid() && agregarViewModel.editedFields.quantityEdited {
                    ErrorMessageText(message: "Cantidad Incorrecta")
                        .padding(.top, 18)
                }
            }
            .listRowBackground(Color("color_background"))
            .listRowSeparator(.hidden)
            .padding(.top, 4)
            // Las palabras Clave se utilizaran el el futuro
            /*
            HStack {
                Text("Palabras Clave")
                    .font(.headline)
                Spacer()
                CampoIndividual(contenido: $productsCoreDataViewModel.temporalProduct.keyWords, edited: .constant(false))
                    .frame(width: sizeCampo)
            }
            .listRowBackground(Color("color_background"))
            .listRowSeparator(.hidden)
            */
            /*
            HStack {
                Text("Fecha Vencimiento")
                    .font(.headline)
                Spacer()
                CampoIndividualDate(contenido: $productsCoreDataViewModel.temporalProduct.expirationDate)
                    .frame(width: sizeCampo)
            }
            .listRowBackground(Color("color_background"))
            .listRowSeparator(.hidden)
             */
            VStack {
                HStack {
                    Text("Costo Unitario")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .font(.custom("Artifika-Regular", size: 18))
                        .padding(.horizontal, 5)
                    Spacer()
                    Text("Margen de Ganancia")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .font(.custom("Artifika-Regular", size: 18))
                        .padding(.horizontal, 5)
                    Spacer()
                    Text("Precio de Venta")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .font(.custom("Artifika-Regular", size: 18))
                        .padding(.horizontal, 5)
                }
                .padding(.top, 15)
                HStack(spacing: 0) {
                    VStack {
                        CampoIndividualDouble(contenido: $productsCoreDataViewModel.temporalProduct.unitCost, edited: $agregarViewModel.editedFields.unitCostEdited, action: productsCoreDataViewModel.calcProfitMargin)
                        if !productsCoreDataViewModel.temporalProduct.isUnitCostValid() && agregarViewModel.editedFields.unitCostEdited {
                            ErrorMessageText(message: "Costo Unitario Incorrecto")
                                .padding(.top, 6)
                        }
                    }
                    Spacer()
                    VStack {
                        CampoIndividualDoubleLocked(contenido: productsCoreDataViewModel.temporalProduct.profitMargin)
                    }
                    Spacer()
                    VStack {
                        CampoIndividualDouble(contenido: $productsCoreDataViewModel.temporalProduct.unitPrice, edited: $agregarViewModel.editedFields.unitPriceEdited, action: productsCoreDataViewModel.calcProfitMargin)
                        if !productsCoreDataViewModel.temporalProduct.isUnitPriceValid() && agregarViewModel.editedFields.unitPriceEdited {
                            ErrorMessageText(message: "Precio Unitario Incorrecto")
                                .padding(.top, 6)
                        }
                    }
                }
                if buttonPress {
                }
            }
            .listRowBackground(Color("color_background"))
            .listRowSeparator(.hidden)
        }
        .listStyle(PlainListStyle())
    }
    func doNothing() {
        // No hace nada
    }
}
private func openGoogleImageSearch(nombre: String) {
    // Limpia la cadena de búsqueda para que sea válida en una URL
    guard let cleanedSearchQuery = nombre.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let googleImageSearchURL = URL(string: "https://www.google.com/search?tbm=isch&q=\(cleanedSearchQuery)") else {
        return
    }
    
    // Abre la URL en Safari mediante SFSafariViewController
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let topViewController = windowScene.windows.first?.rootViewController {
        let safariViewController = SFSafariViewController(url: googleImageSearchURL)
        topViewController.present(safariViewController, animated: true, completion: nil)
    }
}

private func pasteFromClipboard() -> String {
    if let clipboardContent = UIPasteboard.general.string {
        return clipboardContent
    } else {
        return ""
    }
}
