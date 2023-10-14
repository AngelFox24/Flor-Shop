//
//  LogInView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/08/23.
//

import SwiftUI

struct LogInView: View {
    @EnvironmentObject var logInViewModel: LogInViewModel
    @Binding var isKeyboardVisible: Bool
    var body: some View {
        ZStack {
            Color("color_primary")
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 30) {
                    Spacer()
                    Text("Iniciar Sesión")
                        .font(.custom("Artifika-Regular", size: 30))
                        .padding(.bottom, 50)
                    VStack(spacing: 40){
                        VStack {
                            CustomTextField(title: "Usuario o Correo" ,value: $logInViewModel.logInFields.userOrEmail, edited: $logInViewModel.logInFields.userOrEmailEdited, keyboardType: .default)
                            if logInViewModel.logInFields.userOrEmailError != "" {
                                ErrorMessageText(message: logInViewModel.logInFields.userOrEmailError)
                                //.padding(.top, 18)
                            }
                        }
                        VStack {
                            CustomTextField(title: "Contraseña" ,value: $logInViewModel.logInFields.password, edited: $logInViewModel.logInFields.passwordEdited, keyboardType: .default)
                            if logInViewModel.logInFields.passwordError != "" {
                                ErrorMessageText(message: logInViewModel.logInFields.passwordError)
                                //.padding(.top, 18)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    VStack(spacing: 30) {
                        Button(action: {
                            logInViewModel.logIn()
                            logInViewModel.checkDBIntegrity()
                        }, label: {
                            VStack {
                                CustomButton2(text: "Ingresar", backgroudColor: Color("color_accent"), minWidthC: 250)
                                    .foregroundColor(Color(.black))
                                if logInViewModel.logInFields.errorLogIn != "" {
                                    ErrorMessageText(message: logInViewModel.logInFields.errorLogIn)
                                    //.padding(.top, 18)
                                }
                            }
                        })
                        Color(.gray)
                            .frame(width: 280, height: 2)
                        Button(action: {}, label: {
                            CustomButton2(text: "Continuar con Google", backgroudColor: Color("color_secondary"), minWidthC: 250)
                                .foregroundColor(Color(.black))
                        })
                        Button(action: {}, label: {
                            CustomButton2(text: "Continuar con Apple", backgroudColor: Color("color_secondary"), minWidthC: 250)
                                .foregroundColor(Color(.black))
                        })
                    }
                    .padding(.top, 30)
                    Spacer()
                }
            }
            .padding(.top, 1) //Resuelve el problema del desvanecimiento en el navigation back button
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        let companyManager = LocalCompanyManager(mainContext: CoreDataProvider.shared.viewContext)
        let subsidiaryManager = LocalSubsidiaryManager(mainContext: CoreDataProvider.shared.viewContext)
        let customerManager = LocalCustomerManager(mainContext: CoreDataProvider.shared.viewContext)
        let employeeManager = LocalEmployeeManager(mainContext: CoreDataProvider.shared.viewContext)
        let productManager = LocalProductManager(mainContext: CoreDataProvider.shared.viewContext)
        let cartManager = LocalCartManager(mainContext: CoreDataProvider.shared.viewContext)
        let saleManager = LocalSaleManager(mainContext: CoreDataProvider.shared.viewContext)
        let companyRepository = CompanyRepositoryImpl(manager: companyManager)
        let customerRepository = CustomerRepositoryImpl(manager: customerManager)
        let subsidiaryRepository = SubsidiaryRepositoryImpl(manager: subsidiaryManager)
        let employeeRepository = EmployeeRepositoryImpl(manager: employeeManager)
        let productRepository = ProductRepositoryImpl(manager: productManager)
        let cartRepository = CarRepositoryImpl(manager: cartManager)
        let salesRepository = SaleRepositoryImpl(manager: saleManager)
        let logInViewModel = LogInViewModel(companyRepository: companyRepository, subsidiaryRepository: subsidiaryRepository, employeeRepository: employeeRepository, cartRepository: cartRepository, productReporsitory: productRepository, saleRepository: salesRepository, customerRepository: customerRepository)
        LogInView(isKeyboardVisible: .constant(true))
            .environmentObject(logInViewModel)
    }
}
