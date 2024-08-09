//
//  AddCustomerView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 14/10/23.
//

import SwiftUI

struct AddCustomerView: View {
    @EnvironmentObject var addCustomerViewModel: AddCustomerViewModel
    @EnvironmentObject var viewStates: ViewStates
    @FocusState var currentFocusField: AllFocusFields?
    var body: some View {
        ZStack(content: {
            VStack(spacing: 0) {
                AddCustomerTopBar()
                AddCustomerFields(isPresented: $addCustomerViewModel.isPresented, currentFocusField: $currentFocusField)
            }
            .background(Color("color_background"))
            .blur(radius: addCustomerViewModel.isPresented ? 2 : 0)
            if addCustomerViewModel.isPresented {
                SourceSelecctionView(isPresented: $addCustomerViewModel.isPresented, fromInternet: false, selectionImage: $addCustomerViewModel.selectionImage)
            }
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewStates.focusedField, perform: { newVal in
            print("Ext cambio: \(viewStates.focusedField)")
            currentFocusField = viewStates.focusedField
        })
        .onChange(of: currentFocusField, perform: { newVal in
            print("curr cambio: \(currentFocusField)")
            viewStates.focusedField = currentFocusField
        })
        .onAppear {
            self.currentFocusField = viewStates.focusedField    // << read !!
        }
    }
}

struct AddCustomerView_Previews: PreviewProvider {
    static var previews: some View {
        let nor = NormalDependencies()
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        AddCustomerView()
            .environmentObject(dependencies.addCustomerViewModel)
    }
}

struct AddCustomerFields : View {
    @EnvironmentObject var addCustomerViewModel: AddCustomerViewModel
    @Binding var isPresented: Bool
    var currentFocusField: FocusState<AllFocusFields?>.Binding
    var sizeCampo: CGFloat = 150
    var body: some View {
        ScrollView(.vertical, showsIndicators: false, content: {
            VStack(spacing: 23, content: {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeIn) {
                            isPresented = true
                        }
                    }, label: {
                        VStack(content: {
                            if let imageC = addCustomerViewModel.selectedImage {
                                Image(uiImage: imageC)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: sizeCampo, height: sizeCampo)
                                    .cornerRadius(15.0)
                            } else {
                                CardViewPlaceHolder2(size: sizeCampo)
                            }
                        })
                    })
                    Spacer()
                }
                HStack {
                    // El texto hace que tenga una separacion mayor del elemento
                    CustomTextField(title: "Nombre" ,value: $addCustomerViewModel.fieldsAddCustomer.name, edited: $addCustomerViewModel.fieldsAddCustomer.nameEdited, focusField: .addCustomer(.nombre), currentFocusField: currentFocusField)
                }
                if addCustomerViewModel.fieldsAddCustomer.nameError != "" {
                    ErrorMessageText(message: addCustomerViewModel.fieldsAddCustomer.nameError)
                    //.padding(.top, 6)
                }
                HStack {
                    // El texto hace que tenga una separacion mayor del elemento
                    CustomTextField(title: "Apellidos" ,value: $addCustomerViewModel.fieldsAddCustomer.lastname, edited: $addCustomerViewModel.fieldsAddCustomer.lastnameEdited, focusField: .addCustomer(.apellidos), currentFocusField: currentFocusField)
                }
                if addCustomerViewModel.fieldsAddCustomer.lastnameError != "" {
                    ErrorMessageText(message: addCustomerViewModel.fieldsAddCustomer.lastnameError)
                    //.padding(.top, 6)
                }
                HStack(content: {
                    CustomTextField(title: "Móvil" ,value: $addCustomerViewModel.fieldsAddCustomer.phoneNumber, edited: $addCustomerViewModel.fieldsAddCustomer.phoneNumberEdited, focusField: .addCustomer(.movil), currentFocusField: currentFocusField, keyboardType: .numberPad)
                    CustomTextField(title: "Deuda Total" ,value: $addCustomerViewModel.fieldsAddCustomer.totalDebt, edited: .constant(false), focusField: .addCustomer(.deudaTotal), currentFocusField: currentFocusField, disable: true)
                })
                HStack(content: {
                    CustomTextField(title: "Fecha Límite" ,value: .constant(addCustomerViewModel.fieldsAddCustomer.dateLimitString), edited: .constant(false), focusField: .addCustomer(.fechalimite), currentFocusField: currentFocusField, disable: true)
                    CustomTextField(title: "Días de Crédito" ,value: $addCustomerViewModel.fieldsAddCustomer.creditDays, edited: $addCustomerViewModel.fieldsAddCustomer.creditLimitEdited, focusField: .addCustomer(.diascredito), currentFocusField: currentFocusField, disable: !addCustomerViewModel.fieldsAddCustomer.dateLimitFlag, keyboardType: .numberPad)
                    Toggle("", isOn: $addCustomerViewModel.fieldsAddCustomer.dateLimitFlag)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: Color("color_accent")))
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
                    CustomTextField(title: "Límite de Crédito" ,value: $addCustomerViewModel.fieldsAddCustomer.creditLimit, edited: $addCustomerViewModel.fieldsAddCustomer.creditLimitEdited, focusField: .addCustomer(.limitecredito), currentFocusField: currentFocusField, disable: !addCustomerViewModel.fieldsAddCustomer.creditLimitFlag, keyboardType: .numberPad)
                    Toggle("", isOn: $addCustomerViewModel.fieldsAddCustomer.creditLimitFlag)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: Color("color_accent")))
                        .padding(.horizontal, 5)
                })
            })
            .padding(.top, 10)
        })
        .padding(.horizontal, 10)
        .scrollDismissesKeyboard(.immediately)
        .onDisappear {
            Task {
                await addCustomerViewModel.releaseResources()
            }
        }
    }
}
