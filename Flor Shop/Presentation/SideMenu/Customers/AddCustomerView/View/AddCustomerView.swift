import SwiftUI

struct AddCustomerView: View {
    @Environment(FlorShopRouter.self) private var router
    @State var addCustomerViewModel: AddCustomerViewModel
    let customerCic: String?
    init(ses: SessionContainer) {
        addCustomerViewModel = AddCustomerViewModelFactory.getAddCustomerViewModel(sessionContainer: ses)
        self.customerCic = nil
    }
    init(
        ses: SessionContainer,
        customerCic: String
    ) {
        addCustomerViewModel = AddCustomerViewModelFactory.getAddCustomerViewModel(sessionContainer: ses)
        self.customerCic = customerCic
    }
    var body: some View {
        AddCustomerFields(addCustomerViewModel: $addCustomerViewModel)
            .padding(.horizontal, 10)
            .background(Color.background)
            .navigationTitle("Agregar cliente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                MainConfirmationToolbar(disabled: false, action: addCustomer)
            }
            .task {
                guard let customerCic else { return }
                addCustomerViewModel.loadCustomer(customerCic: customerCic)
            }
    }
    func addCustomer() {
        Task {
//            router.isLoading = true
            do {
                try await addCustomerViewModel.addCustomer()
                router.back()
            } catch {
                print("Error al agregar cliente: \(error)")
            }
//            router.isLoading = false
        }
    }
}

#Preview {
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    AddCustomerView(ses: SessionContainer.preview)
        .environment(mainRouter)
}

struct AddCustomerFields : View {
    @Binding var addCustomerViewModel: AddCustomerViewModel
    var sizeCampo: CGFloat = 150
    var body: some View {
        ScrollView(.vertical, showsIndicators: false, content: {
            VStack(spacing: 23, content: {
                HStack {
                    Spacer()
                    CustomImageView(
                        uiImage: $addCustomerViewModel.selectedImage,
                        size: sizeCampo,
                        searchFromInternet: nil,
                        searchFromGallery: searchFromGallery,
                        takePhoto: takePhoto
                    )
                    .photosPicker(isPresented: $addCustomerViewModel.fieldsAddCustomer.isShowingPicker,
                                  selection: $addCustomerViewModel.selectionImage,
                                  matching: .any(of: [.images, .screenshots]))
                    Spacer()
                }
                HStack {
                    // El texto hace que tenga una separacion mayor del elemento
                    CustomTextField(title: "Nombre" ,value: $addCustomerViewModel.fieldsAddCustomer.name, edited: $addCustomerViewModel.fieldsAddCustomer.nameEdited)
                }
                if addCustomerViewModel.fieldsAddCustomer.nameError != "" {
                    ErrorMessageText(message: addCustomerViewModel.fieldsAddCustomer.nameError)
                    //.padding(.top, 6)
                }
                HStack {
                    // El texto hace que tenga una separacion mayor del elemento
                    CustomTextField(title: "Apellidos" ,value: $addCustomerViewModel.fieldsAddCustomer.lastname, edited: $addCustomerViewModel.fieldsAddCustomer.lastnameEdited)
                }
                if addCustomerViewModel.fieldsAddCustomer.lastnameError != "" {
                    ErrorMessageText(message: addCustomerViewModel.fieldsAddCustomer.lastnameError)
                    //.padding(.top, 6)
                }
                HStack(content: {
                    CustomTextField(title: "Móvil" ,value: $addCustomerViewModel.fieldsAddCustomer.phoneNumber, edited: $addCustomerViewModel.fieldsAddCustomer.phoneNumberEdited, keyboardType: .numberPad)
//                    CustomTextField(title: "Deuda Total" ,value: $addCustomerViewModel.fieldsAddCustomer.totalDebt, edited: .constant(false), disable: true)
                    CustomNumberField(title: "Deuda Total", userInput: $addCustomerViewModel.fieldsAddCustomer.totalDebt, edited: .constant(false), disable: true)
                })
                HStack(content: {
                    CustomTextField(title: "Fecha Límite" ,value: .constant(addCustomerViewModel.fieldsAddCustomer.dateLimitString), edited: .constant(false), disable: true)
                    CustomTextField(title: "Días de Crédito" ,value: $addCustomerViewModel.fieldsAddCustomer.creditDays, edited: $addCustomerViewModel.fieldsAddCustomer.creditLimitEdited, disable: !addCustomerViewModel.fieldsAddCustomer.dateLimitFlag, keyboardType: .numberPad)
                    Toggle("", isOn: $addCustomerViewModel.fieldsAddCustomer.dateLimitFlag)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        .padding(.horizontal, 5)
                })
                Text("* La Fecha Límite se calcula desde el primer consumo a crédito del cliente y se reinicia cuando paga el total del crédito.")
                    .font(.custom("Artifika-Regular", size: 12))
                    .foregroundColor(.black)
                    .opacity(0.8)
                if addCustomerViewModel.fieldsAddCustomer.creditDaysError != "" {
                    ErrorMessageText(message: addCustomerViewModel.fieldsAddCustomer.creditDaysError)
                }
                HStack(content: {
                    CustomNumberField(title: "Límite de Crédito", userInput: $addCustomerViewModel.fieldsAddCustomer.creditLimit, edited: $addCustomerViewModel.fieldsAddCustomer.creditLimitEdited, disable: !addCustomerViewModel.fieldsAddCustomer.creditLimitFlag)
                    Toggle("", isOn: $addCustomerViewModel.fieldsAddCustomer.creditLimitFlag)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        .padding(.horizontal, 5)
                })
            })
            .padding(.top, 10)
        })
        .scrollDismissesKeyboard(.immediately)
    }
    func searchFromGallery() {
        addCustomerViewModel.fieldsAddCustomer.isShowingPicker = true
    }
    func takePhoto() {
        
    }
}
