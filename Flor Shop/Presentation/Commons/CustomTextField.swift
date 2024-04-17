//
//  CustomTextField.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 9/08/23.
//

import SwiftUI

struct CustomTextField: View {
    var title: String = "Campo"
    @Binding var value: String
    @Binding var edited: Bool
    @FocusState var isTextFieldFocused
    var disable: Bool = false
    var onSubmit: (() -> Void)?
    var onUnFocused: (() -> Void)?
    var keyboardType: UIKeyboardType = .default
    var disableAutocorrection: Bool = true
    var body: some View {
        HStack {
            ZStack {
                    HStack(spacing: 0) {
                        TextField("", text: $value)
                            .focused($isTextFieldFocused)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 20))
                            .multilineTextAlignment(.center)
                            .keyboardType(keyboardType)
                            .padding(.all, 5)
                            .foregroundColor(.black)
                            .padding(.vertical, 4)
                            .disableAutocorrection(disableAutocorrection)
                            .onTapGesture {
                                isTextFieldFocused = true
                            }
                            .onChange(of: value, perform: {text in
                                if isTextFieldFocused {
                                    if text != "" {
                                        edited = true
                                    }
                                }
                            })
                            .onSubmit({
                                if value != "" {
                                    onSubmit?()
                                }
                            })
                            .onChange(of: isTextFieldFocused, perform: {focus in
                                if focus == false {
                                    print("Se ejecuta UnFocused")
                                    onUnFocused?()
                                }
                            })
                            .disabled(disable)
                        if isTextFieldFocused {
                            Button(action: {
                                if isTextFieldFocused {
                                    value.removeAll()
                                } else if !disable {
                                    isTextFieldFocused = true
                                }
                            }, label: {
                                Image(systemName: "x.circle")
                                    .foregroundColor(Color("color_accent"))
                                    .font(.custom("Artifika-Regular", size: 16))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 12)
                                    //.opacity(isTextFieldFocused ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.4), value: isTextFieldFocused)
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
                        .onTapGesture {
                            if !disable {
                                isTextFieldFocused = true
                            }
                        }
                        .disabled(disable)
            }
        }
    }
}
struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        @State var dato: String = "Prueba"
        HStack(spacing: 6) {
            //CustomTextField(title: "Nombre del producto",value: $dato ,edited: .constant(false), keyboardType: .numberPad)
            CustomTextField(value: $dato, edited: .constant(false), disable: false, keyboardType: .numberPad)
            //CustomText(title: "Nombre", value: "", disable: true)
            //CustomTextField(edited: .constant(false))
        }
        .frame(maxHeight: .infinity)
        .background(Color("color_accent"))
    }
}
