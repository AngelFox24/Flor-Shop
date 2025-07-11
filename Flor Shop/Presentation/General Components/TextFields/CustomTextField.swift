//
//  CustomTextField.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 9/08/23.
//

import SwiftUI

struct CustomTextField: View {
    var placeHolder: String = ""
    var title: String = "Campo"
    @Binding var value: String
    @Binding var edited: Bool
    @FocusState var isInputActive: Bool
    var disable: Bool = false
    var keyboardType: UIKeyboardType = .default
    var disableAutocorrection: Bool = true
    var body: some View {
        HStack {
            ZStack {
                HStack(spacing: 0) {
                    TextField(placeHolder, text: $value)
                        .focused($isInputActive)
                        .foregroundColor(.black)
                        .font(.custom("Artifika-Regular", size: 20))
                        .multilineTextAlignment(.center)
                        .keyboardType(keyboardType)
                        .padding(.all, 5)
                        .foregroundColor(.black)
                        .padding(.vertical, 4)
                        .disableAutocorrection(disableAutocorrection)
                        .onChange(of: value, perform: { text in
                            if isInputActive {
                                if text != "" {
                                    edited = true
                                }
                            }
                        })
                        .disabled(disable)
                        .toolbar {
                            if isInputActive {
                                ToolbarItemGroup(placement: .keyboard) {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            isInputActive = false
                                        }, label: {
                                            Image(systemName: "keyboard.chevron.compact.down")
                                                .font(.system(size: 20))
                                                .foregroundColor(Color("color_accent"))
                                                .padding(.trailing, 50)
                                                .padding(.vertical, 10)
                                        })
                                    }
                                    .background(Color("color_primary"))
                                    .frame(width: UIScreen.main.bounds.width)
                                }
                            }
                        }
                    if isInputActive && !value.isEmpty {
                        Button(action: {
                            if isInputActive {
                                value.removeAll()
                            } else if !disable {
                                isInputActive = true
                            }
                        }, label: {
                            Image(systemName: "x.circle")
                                .foregroundColor(Color("color_accent"))
                                .font(.custom("Artifika-Regular", size: 16))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                                .animation(.easeInOut(duration: 0.9), value: isInputActive)
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
                isInputActive = true
            }
        }
    }
}

#Preview {
    @Previewable @State var name = ""
    @Previewable @State var qt = ""
    @Previewable @State var ed = false
    @Previewable @State var ed1 = false
    VStack(spacing: 16) {
        CustomTextField(value: $name, edited: $ed)
        CustomTextField(value: $qt, edited: $ed1)
        //CustomText(title: "Nombre", value: "", disable: true)
        //CustomTextField(edited: .constant(false))
    }
    .frame(maxHeight: .infinity)
    .background(Color.accent)
}
