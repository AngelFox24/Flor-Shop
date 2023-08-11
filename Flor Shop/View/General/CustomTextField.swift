//
//  CustomTextField.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 9/08/23.
//

import SwiftUI

struct CustomTextField: View {
    var title: String = "Campo"
    @State var value: String = ""
    @Binding var edited: Bool
    @FocusState var isTextFieldFocused
    var disable: Bool = false
    var body: some View {
            ZStack {
                HStack(spacing: 0) {
                    TextField("", text: $value)
                        .focused($isTextFieldFocused)
                        .foregroundColor(.black)
                        .font(.custom("Artifika-Regular", size: 18))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .padding(.all, 5)
                        .foregroundColor(.black)
                        .disabled(disable)
                        Button(action: {
                            if isTextFieldFocused {
                                value = ""
                            }
                            isTextFieldFocused = true
                        }, label: {
                            Image(systemName: "x.circle")
                                .foregroundColor(Color("color_accent"))
                                .font(.custom("Artifika-Regular", size: 16))
                                .padding(.horizontal, 2)
                                .padding(.vertical, 8)
                                .opacity(isTextFieldFocused ? 1 : 0)
                                .animation(.easeInOut(duration: 0.4), value: isTextFieldFocused)
                        })
                }
                .background(disable ? Color(hue: 1.0, saturation: 0.0, brightness: 0.884) : .white)
                .cornerRadius(8)
                Text(title)
                    .font(.custom("Artifika-Regular", size: 12))
                    .padding(.horizontal, 8)
                    .foregroundColor(.black)
                    .background(disable ? Color(hue: 1.0, saturation: 0.0, brightness: 0.884) : .white)
                    .cornerRadius(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(y: -22)
                    .onTapGesture {
                        isTextFieldFocused = true
                    }
                    .disabled(disable)
            }
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 6) {
            CustomTextField(title: "Nombre del producto" ,edited: .constant(false))
            CustomTextField(edited: .constant(false), disable: false)
            //CustomTextField(edited: .constant(false))
        }
        .frame(maxHeight: .infinity)
        .background(Color("color_background"))
    }
}
