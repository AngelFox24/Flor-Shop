//
//  AddCustomerView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 14/10/23.
//

import SwiftUI

struct AddCustomerView: View {
    var body: some View {
        VStack(spacing: 0) {
            AddCustomerTopBar()
            AddCustomerFields()
        }
        .background(Color("color_background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct AddCustomerView_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        AddCustomerView()
            .environmentObject(dependencies.addCustomerViewModel)
    }
}

struct AddCustomerFields : View {
    @EnvironmentObject var addCustomerViewModel: AddCustomerViewModel
    var sizeCampo: CGFloat = 150
    var body: some View {
        ScrollView(content: {
            VStack(spacing: 23, content: {
                HStack {
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        CardViewPlaceHolder2(size: sizeCampo)
                    })
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
                    CustomTextField(title: "Deuda Total" ,value: $addCustomerViewModel.fieldsAddCustomer.totalDebt, edited: .constant(false), disable: true)
                })
                HStack(content: {
                    CustomText(title: "Fecha Límite" ,value: addCustomerViewModel.fieldsAddCustomer.dateLimitString, disable: true)
                    CustomTextField(title: "Días de Crédito" ,value: $addCustomerViewModel.fieldsAddCustomer.creditDays, edited: $addCustomerViewModel.fieldsAddCustomer.creditLimitEdited, disable: !addCustomerViewModel.fieldsAddCustomer.dateLimitFlag, keyboardType: .numberPad)
                    Toggle("", isOn: $addCustomerViewModel.fieldsAddCustomer.dateLimitFlag)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: Color("color_accent")))
                        .padding(.horizontal, 5)
                })
                Text("* La Fecha Límite de calcula desde el primer consumo a crédito del cliente y se reinicia cuando paga el total del crédito.")
                    .font(.custom("Artifika-Regular", size: 12))
                    .foregroundColor(.black)
                    .opacity(0.8)
                if addCustomerViewModel.fieldsAddCustomer.creditDaysError != "" {
                    ErrorMessageText(message: addCustomerViewModel.fieldsAddCustomer.creditDaysError)
                }
                HStack(content: {
                    CustomTextField(title: "Límite de Crédito" ,value: $addCustomerViewModel.fieldsAddCustomer.creditLimit, edited: $addCustomerViewModel.fieldsAddCustomer.creditLimitEdited, disable: !addCustomerViewModel.fieldsAddCustomer.creditLimitFlag, keyboardType: .numberPad)
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
    }
}
