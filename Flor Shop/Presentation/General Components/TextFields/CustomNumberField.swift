import SwiftUI

struct CustomNumberField: View {
    var title: String
    @State private var firstFocusTriggered = false
    @State private var viewText: String = ""
    @Binding var userInput: Int
    @Binding var edited: Bool
    @FocusState var isInputActive: Bool
    var disable: Bool
    var onUnFocused: (() -> Void)?
    let numberOfDecimals: Int
    private var placeHolderPerform: Bool { isInputActive || !viewText.isEmpty }
    init(
        title: String = "Campo",
        userInput: Binding<Int>,
        edited: Binding<Bool>,
        disable: Bool = false,
        onUnFocused: (() -> Void)? = nil,
        numberOfDecimals: Int = 2
    ) {
        self.title = title
        self._userInput = userInput
        self._edited = edited
        self.disable = disable
        self.onUnFocused = onUnFocused
        self.numberOfDecimals = numberOfDecimals
    }
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                TextField("", text: $viewText)
                    .focused($isInputActive)
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
                            print("[CustomNumberField] stringsito: \(stringsito)")
                            if let val = Int(stringsito) {
                                userInput = val
                                viewText = formatCustomDecimal(val)
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
                            viewText = formatCustomDecimal(userInput)
                        }
                    }
                    .disabled(disable)
                    .toolbar {
                        if isInputActive {
                            ToolbarItem(placement: .keyboard) {
                                CustomHideKeyboard {
                                    isInputActive = false
                                }
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
                            .foregroundColor(Color.accentColor)
                            .font(.custom("Artifika-Regular", size: 16))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
                            .animation(.easeInOut(duration: 0.4), value: isInputActive)
                    })
                }
            }
            .background(disable ? Color.textFieldDisable : .white)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            HStack {
                Text(title)
                    .font(.custom("Artifika-Regular", size: placeHolderPerform ? 14 : 20))
                    .padding(.horizontal, 10)
                    .foregroundColor(Color.textFieldTittle)
                    .disabled(disable)
                Spacer()
            }
            .offset(y: placeHolderPerform ? -34 : 0)
            .animation(.easeOut(duration: 0.2), value: placeHolderPerform)
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
                viewText = formatCustomDecimal(userInput)
            }
        }
    }
    func formatCustomDecimal(_ input: Int) -> String {
        let s = String(input)
        guard numberOfDecimals >= 0 else { return s }
        let newCeros = max((self.numberOfDecimals+1) - s.count, 0)
        var newString = String(repeating: "0", count: newCeros) + s
        if self.numberOfDecimals > 0 {
            let index = newString.index(newString.endIndex, offsetBy: -numberOfDecimals)
            newString.insert(".", at: index)
        }
        return newString
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
    .background(Color.background)
}
