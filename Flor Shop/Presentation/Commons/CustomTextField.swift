//
//  CustomTextField.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 9/08/23.
//

import SwiftUI

struct CustomTextField: View {
    @EnvironmentObject var viewStates: ViewStates
    var placeHolder: String = ""
    var title: String = "Campo"
    @Binding var value: String
    @Binding var edited: Bool
    let focusField: AllFocusFields
    var currentFocusField: FocusState<AllFocusFields?>.Binding
    private var isEqual: Bool { currentFocusField.wrappedValue == focusField }
    var disable: Bool = false
    var keyboardType: UIKeyboardType = .default
    var disableAutocorrection: Bool = true
    var body: some View {
        HStack {
            ZStack {
                HStack(spacing: 0) {
                    TextField(placeHolder, text: $value)
                        .focused(currentFocusField, equals: focusField)
                        .foregroundColor(.black)
                        .font(.custom("Artifika-Regular", size: 20))
                        .multilineTextAlignment(.center)
                        .keyboardType(keyboardType)
                        .padding(.all, 5)
                        .foregroundColor(.black)
                        .padding(.vertical, 4)
                        .disableAutocorrection(disableAutocorrection)
                        .onChange(of: value, perform: { text in
                            print("Custom: \(text)")
                            print("Ext: \(value)")
                            if isEqual {
                                if text != "" {
                                    edited = true
                                }
                            }
                        })
                        .disabled(disable)
                    if isEqual && !value.isEmpty {
                        Button(action: {
                            if isEqual {
                                print("Removed")
                                value.removeAll()
                            } else if !disable {
                                viewStates.focusedField = focusField
                            }
                        }, label: {
                            Image(systemName: "x.circle")
                                .foregroundColor(Color("color_accent"))
                                .font(.custom("Artifika-Regular", size: 16))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                                .animation(.easeInOut(duration: 0.9), value: isEqual)
                        })
                    }
                }
                .background(disable ? Color(hue: 1.0, saturation: 0.0, brightness: 0.884) : .white)
                .cornerRadius(8)
                Text(title)
                    .font(.custom("Artifika-Regular", size: 14))
                    .padding(.horizontal, 8)
                    .foregroundColor(.black)
                    .background(disable ? Color(hue: 1.0, saturation: 0.0, brightness: 0.884) : .white)
                    .cornerRadius(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(y: -22)
                    .disabled(disable)
            }
        }
        .onTapGesture {
            if !disable {
                viewStates.focusedField = focusField
            }
        }
    }
}

class AgregarViewModelTem: ObservableObject {
    @ObservedObject var campos = AgregarFields()
}

struct ViewCss1: View {
    let nor = NormalDependencies()
    @State var agregarFields: AgregarViewModelTem = AgregarViewModelTem()
    @FocusState var currentFocusField: AllFocusFields?
    var body: some View {
        ViewCss2(fields: agregarFields.campos, currentFocusField: $currentFocusField)
        .environmentObject(nor.viewStates)
    }
}

struct ViewCss2: View {
    @ObservedObject var fields: AgregarFields
    var currentFocusField: FocusState<AllFocusFields?>.Binding
    var body: some View {
        VStack(spacing: 16) {
            CustomTextField(value: $fields.productName, edited: $fields.productEdited, focusField: .agregar(.productName), currentFocusField: currentFocusField)
            CustomTextField(value: $fields.quantityStock, edited: $fields.quantityEdited, focusField: .agregar(.quantity), currentFocusField: currentFocusField)
            //CustomText(title: "Nombre", value: "", disable: true)
            //CustomTextField(edited: .constant(false))
        }
        .frame(maxHeight: .infinity)
        .background(Color("color_accent"))
    }
}

#Preview {
    ViewCss1()
}
