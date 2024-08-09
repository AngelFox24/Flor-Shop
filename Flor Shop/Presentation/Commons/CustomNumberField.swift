//
//  CustomNumberField.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 03/08/2024.
//

import SwiftUI

struct CustomNumberField: View {
    @EnvironmentObject var viewStates: ViewStates
    var placeHolder: String = "0.00"
    var title: String = "Campo"
    @State private var viewText: String = ""
    @Binding var userInput: Int
    @Binding var edited: Bool
    let focusField: AllFocusFields
    var currentFocusField: FocusState<AllFocusFields?>.Binding
    private var isEqual: Bool { currentFocusField.wrappedValue == focusField }
    var disable: Bool = false
    var onUnFocused: (() -> Void)?
    var body: some View {
        HStack {
            ZStack {
                    HStack(spacing: 0) {
                        TextField(placeHolder, text: $viewText)
                            .focused(currentFocusField, equals: focusField)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 20))
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .padding(.all, 5)
                            .foregroundColor(.black)
                            .padding(.vertical, 4)
                            .disableAutocorrection(true)
                            .onChange(of: viewText, perform: { newValue in
                                if isEqual {
                                    if newValue != "" {
                                        edited = true
                                    }
                                    let stringsito = newValue.replacingOccurrences(of: ".", with: "")
                                    if let val = Int(stringsito) {
                                        userInput = val
                                        viewText = formatNumber(val)
                                    } else {
                                        viewText = "0"
                                    }
                                }
                            })
                            .onChange(of: isEqual, perform: { focus in
                                if focus == false {
                                    print("Se ejecuta UnFocused")
                                    onUnFocused?()
                                }
                            })
                            .disabled(disable)
                        if isEqual {
                            Button(action: {
                                if isEqual {
                                    viewText.removeAll()
                                } else if !disable {
                                    viewStates.focusedField = focusField
                                }
                            }, label: {
                                Image(systemName: "x.circle")
                                    .foregroundColor(Color("color_accent"))
                                    .font(.custom("Artifika-Regular", size: 16))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 12)
                                    //.opacity(isTextFieldFocused ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.4), value: isEqual)
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
        .onAppear {
            viewText = formatNumber(userInput)
        }
    }
    func formatNumber(_ input: Int) -> String {
        let inputString = String(input)
        let count = inputString.count
        
        switch count {
        case 0:
            return "0.00"
        case 1:
            return "0.0\(inputString)"
        default:
            let index = inputString.index(inputString.endIndex, offsetBy: -2)
            let wholePart = String(inputString[..<index])
            let decimalPart = String(inputString[index...])
            return "\(wholePart == "" ? "0" : wholePart).\(decimalPart)"
        }
    }
}

struct prevThis: View {
    var body: some View {
        @FocusState var currentFocusField: AllFocusFields?
        CustomNumberField(userInput: .constant(34), edited: .constant(false), focusField: .addCustomer(.apellidos), currentFocusField: $currentFocusField)
    }
}

#Preview {
    prevThis()
}
