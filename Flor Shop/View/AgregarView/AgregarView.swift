//
//  AgregarView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/04/23.
//

import SwiftUI
import CoreData

struct AgregarView: View {
    @State var editedFields = AgregarViewModel()
    var body: some View {
        VStack(spacing: 0){
            AgregarTopBar(editedFields: $editedFields)
            CamposProductoAgregar(editedFields: $editedFields.editedFields)
        }
        .background(Color("color_background"))
    }
}

struct AgregarView_Previews: PreviewProvider {
    static var previews: some View {
        let prdManager = LocalProductManager(containerBDFlor: CoreDataProvider.shared.persistContainer)
        let repository = ProductRepositoryImpl(manager: prdManager)
        AgregarView()
            .environmentObject(ProductViewModel(productRepository: repository))
    }
}

struct CampoIndividual:View {
    @Binding var contenido:String
    @Binding var edited:Bool
    var body: some View {
        VStack {
            TextField("", text: $contenido)
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .onTapGesture {
                    withAnimation {
                        contenido.removeAll()
                        edited = true
                    }
                }
        }
        .padding(.all,5)
        .background(.white)
        .cornerRadius(15)
    }
}

struct CampoIndividualDoubleLocked:View {
    var contenido:Double
    var body: some View {
        VStack {
            Text(String(format: "%.0f", (contenido * 100).rounded())+" %")
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .disabled(true)
                .frame(maxWidth: .infinity)
        }
        .padding(.all,5)
        .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.884))
        .cornerRadius(15)
    }
}

struct CampoIndividualDouble:View {
    @Binding var contenido:Double
    @State var value: String = "0"
    @State private var oldValue: String = ""
    @FocusState var focus: Bool
    @Binding var edited:Bool
    var action: () -> Void
    var disableInput:Bool = false
    var body: some View {
        VStack {
            TextField("", text: $value)
                .font(.system(size: 20))
                .disabled(disableInput)
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .focused($focus)
                .onTapGesture {
                    withAnimation {
                        contenido = 0.0
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
                                let _ = print("Contedido \(contenido) Old: \(oldValue) Value: \(value)")
                            } else {
                                let _ = print("old")
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
                    }else{
                        let _ = print ("no se imp")
                    }
                })
                .onAppear(perform: {
                    value = String(contenido)
                })
        }
        .padding(.all,5)
        .background(.white)
        .cornerRadius(15)
    }
}

struct CampoIndividualInt:View {
    @Binding var contenido:Double
    @State var value: String = "0"
    @State private var oldValue: String = ""
    @FocusState var focus: Bool
    @Binding var edited:Bool
    var action: () -> Void
    var disableInput:Bool = false
    var body: some View {
        VStack {
            TextField("", text: $value)
                .font(.system(size: 20))
                .disabled(disableInput)
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
                                contenido = Double(valueDouble)
                                let _ = print("Contedido \(contenido) Old: \(oldValue) Value: \(value)")
                            } else {
                                let _ = print("old")
                                value = oldValue
                            }
                        }
                    }
                    action()
                })
                .onChange(of: value, perform: { _ in
                    action()
                    if let valueDouble: Int = Int(value) {
                        contenido = Double(valueDouble)
                    }else{
                        let _ = print ("no se imp")
                    }
                })
                .onAppear(perform: {
                    value = String(contenido)
                })
        }
        .padding(.all,5)
        .background(.white)
        .cornerRadius(15)
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
    @Binding var editedFields: FieldEditTemporal
    /*
    @State var productEdited:Bool = false
    @State var totalCostEdited:Bool = false
    @State var quantityEdited:Bool = false
    @State var imageURLEdited:Bool = false
    @State var imageURLError:String = ""
    @State var unitCostEdited:Bool = false
    @State var profitMarginEdited:Bool = false
    @State var unitPriceEdited:Bool = false
    */
    var sizeCampo:CGFloat = 200
    var body: some View{
        List{
            HStack {
                Spacer()
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
                    CampoIndividual(contenido: $productsCoreDataViewModel.temporalProduct.name, edited: $editedFields.productEdited)
                    if (!productsCoreDataViewModel.temporalProduct.isProductNameValid() && editedFields.productEdited){
                        ErrorMessageText(message: "Nombre no válido")
                    }
                }
                .frame(width: sizeCampo)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color("color_background"))
            //El costo total se ultizara en el futuro
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
            HStack {
                Text("Cantidad")
                    .font(.headline)
                Spacer()
                HStack {
                    CampoIndividualInt(contenido: $productsCoreDataViewModel.temporalProduct.qty, edited: $editedFields.quantityEdited, action: doNothing)
                    Menu {
                        /*
                        Button(){
                            productsCoreDataViewModel.temporalProduct.type = .Kg
                        } label: {
                            Text("Kilos")
                        }
                         */
                        Button(){
                            productsCoreDataViewModel.temporalProduct.type = .Uni
                        } label: {
                            Text("Unidades")
                        }
                    }label: {
                        Text(productsCoreDataViewModel.temporalProduct.type.description)
                            .padding(.vertical,7)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal,10)
                    .background(Color("color_secondary"))
                    .cornerRadius(10)
                }
                .frame(width: sizeCampo)
            }
            .listRowBackground(Color("color_background"))
            .listRowSeparator(.hidden)
            VStack {
                HStack {
                    Text("Imagen URL")
                        .font(.headline)
                    Spacer()
                    CampoIndividual(contenido: $productsCoreDataViewModel.temporalProduct.url, edited: $editedFields.imageURLEdited)
                        .frame(width: sizeCampo)
                }
                if (!productsCoreDataViewModel.temporalProduct.isURLValid() && editedFields.imageURLEdited){
                    ErrorMessageText(message: "URL no valido")
                }
            }
            .listRowBackground(Color("color_background"))
            .listRowSeparator(.hidden)
            //Las palabras Clave se utilizaran el el futuro
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
                HStack{
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
                }
                .padding(.top,15)
                HStack(spacing: 0){
                    CampoIndividualDouble(contenido: $productsCoreDataViewModel.temporalProduct.unitCost, edited: $editedFields.unitCostEdited, action: productsCoreDataViewModel.calcProfitMargin)
                    Spacer()
                    //CampoIndividualDouble(contenido: $productsCoreDataViewModel.temporalProduct.profitMargin, disableInput: true)
                    CampoIndividualDoubleLocked(contenido: productsCoreDataViewModel.temporalProduct.profitMargin)
                    Spacer()
                    CampoIndividualDouble(contenido: $productsCoreDataViewModel.temporalProduct.unitPrice, edited: $editedFields.unitPriceEdited, action: productsCoreDataViewModel.calcProfitMargin)
                }
                .padding(.bottom,10)
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

