import SwiftUI

struct CustomNumberField: View {
    var placeHolder: String = "0.00"
    var title: String = "Campo"
    @State private var firstFocusTriggered = false
    @State private var viewText: String = ""
    @Binding var userInput: Int
    @Binding var edited: Bool
    @FocusState var isInputActive: Bool
    var disable: Bool = false
    var onUnFocused: (() -> Void)?
    var body: some View {
        HStack {
            ZStack {
                    HStack(spacing: 0) {
                        TextField(placeHolder, text: $viewText)
                            .focused($isInputActive)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 20))
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .padding(.all, 5)
                            .foregroundColor(.black)
                            .padding(.vertical, 4)
                            .disableAutocorrection(true)
                            .onChange(of: viewText) { _, newValue in
                                if isInputActive {
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
                            }
                            .onChange(of: isInputActive) { _, newFocus in
                                if !newFocus {
                                    onUnFocused?()
                                    if userInput == 0 {//Cuando el teclado desaparece que aparesca el placeholder
                                        viewText = ""
                                        edited = false
                                    }
                                }
                            }
                            .onChange(of: userInput) { _, newValue in
                                if newValue == 0 {
                                    if isInputActive {//Si el teclado esta en pantalla no se puede limpiar el texto porque ocurre errores
                                        viewText = "0"
                                    } else {
                                        viewText = ""
                                    }
                                } else if !isInputActive {//Si no se esta editando y cambia el input entonces actualizamos el texto mostrado, es porque el input se actualizado desde fuera del CustomNumberField
                                    viewText = formatNumber(userInput)
                                }
                            }
                            .disabled(disable)
                            .toolbar {
                                if isInputActive {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        CustomHideKeyboard(action: {
                                            isInputActive = false
                                        })
                                        .frame(width: UIScreen.main.bounds.width)
                                    }
                                }
                            }
                        if isInputActive {
                            Button(action: {
                                if isInputActive {
                                    viewText.removeAll()
                                } else if !disable {
                                    isInputActive = true
                                }
                            }, label: {
                                Image(systemName: "x.circle")
                                    .foregroundColor(Color("color_accent"))
                                    .font(.custom("Artifika-Regular", size: 16))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 12)
                                    .animation(.easeInOut(duration: 0.4), value: isInputActive)
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
        .onAppear() {
            if userInput == 0 {
                viewText = ""
            } else {
                viewText = formatNumber(userInput)
            }
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

#Preview {
    @Previewable @State var userInput: Int = 120
    @Previewable @State var edited: Bool = false
    VStack {
        Spacer()
        CustomNumberField(userInput: $userInput, edited: $edited)
        Spacer()
    }
    .background(Color.gray.opacity(0.9))
}
