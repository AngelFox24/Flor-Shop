import SwiftUI

struct CustomTextField: View {
    let title: String
    @Binding var value: String
    @Binding var edited: Bool
    @FocusState var isInputActive: Bool
    let disable: Bool
    let keyboardType: UIKeyboardType
    let disableAutocorrection: Bool
    let alignment: TextAlignment
    private var placeHolderPerform: Bool { isInputActive || !value.isEmpty }
    init(
        title: String = "Campo",
        value: Binding<String>,
        edited: Binding<Bool>,
        disable: Bool = false,
        keyboardType: UIKeyboardType = .default,
        disableAutocorrection: Bool = true,
        alignment: TextAlignment = .center
    ) {
        self.title = title
        self._value = value
        self._edited = edited
        self.disable = disable
        self.keyboardType = keyboardType
        self.disableAutocorrection = disableAutocorrection
        self.alignment = alignment
    }
    
    @State private var isKeyboardShowing = false
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 24)
            ZStack {
                HStack(spacing: 0) {
                    TextField("", text: $value)
                        .focused($isInputActive)
                        .font(.custom("Artifika-Regular", size: 20))
                        .multilineTextAlignment(alignment)
                        .keyboardType(keyboardType)
                        .padding(.all, 5)
                        .foregroundColor(.black)
                        .padding(.vertical, 4)
                        .disableAutocorrection(disableAutocorrection)
                        .onChange(of: value) { oldText, newText in
                            if isInputActive {
                                if newText != "" {
                                    edited = true
                                }
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
                    if isInputActive && !value.isEmpty {
                        Button {
                            if isInputActive {
                                value.removeAll()
                            } else if !disable {
                                isInputActive = true
                            }
                        } label: {
                            Image(systemName: "x.circle")
                                .foregroundColor(Color.accentColor)
                                .font(.custom("Artifika-Regular", size: 16))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                                .animation(.easeInOut(duration: 0.9), value: isInputActive)
                        }
                    }
                }
                .background(disable ? Color.textFieldDisable : Color.white)
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
//        CustomTextField(value: $qt, edited: $ed1)
        //CustomText(title: "Nombre", value: "", disable: true)
        //CustomTextField(edited: .constant(false))
    }
    .frame(maxHeight: .infinity)
    .background(Color.background)
}
