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
        let customerManager = LocalCustomerManager(mainContext: CoreDataProvider.shared.viewContext)
        let customerRepository = CustomerRepositoryImpl(manager: customerManager)
        let addCustomerViewModel = AddCustomerViewModel(customerRepository: customerRepository)
        AddCustomerView()
            .environmentObject(addCustomerViewModel)
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
                    CustomTextField(title: "Móvil" ,value: $addCustomerViewModel.fieldsAddCustomer.phoneNumber, edited: $addCustomerViewModel.fieldsAddCustomer.phoneNumberEdited)
                    CustomTextField(title: "Deuda Total" ,value: $addCustomerViewModel.fieldsAddCustomer.totalDebt, edited: .constant(false), disable: true)
                })
                HStack(content: {
                    CustomTextField(title: "Fecha Límite" ,value: $addCustomerViewModel.fieldsAddCustomer.lastname, edited: $addCustomerViewModel.fieldsAddCustomer.lastnameEdited, disable: !addCustomerViewModel.fieldsAddCustomer.dateLimitFlag)
                    Toggle("", isOn: $addCustomerViewModel.fieldsAddCustomer.dateLimitFlag)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: Color("color_accent")))
                        .padding(.horizontal, 5)
                })
                HStack(content: {
                    CustomTextField(title: "Límite de Crédito" ,value: $addCustomerViewModel.fieldsAddCustomer.creditLimit, edited: $addCustomerViewModel.fieldsAddCustomer.creditLimitEdited, disable: !addCustomerViewModel.fieldsAddCustomer.creditLimitFlag)
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
