//
//  CreateAccountView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/08/23.
//

import SwiftUI

struct CreateAccountView: View {
    @EnvironmentObject var logInViewModel: LogInViewModel
    @EnvironmentObject var registrationViewModel: RegistrationViewModel
    @EnvironmentObject var navManager: NavManager
    @Binding var isKeyboardVisible: Bool
    var body: some View {
        ZStack {
            Color("color_primary")
                .ignoresSafeArea()
            VStack(content: {
                HStack(content: {
                    Button(action: {
                        navManager.goToBack()
                    }, label: {
                        CustomButton3()
                    })
                    Spacer()
                    Text("Crea una Cuenta")
                        .font(.custom("Artifika-Regular", size: 25))
                    Spacer()
                    Spacer()
                        .frame(width: 40, height: 40)
                })
                .padding(.horizontal, 15)
                ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 40){
                            VStack {
                                CustomTextField(title: "Correo" ,value: $registrationViewModel.registrationFields.email, edited: $registrationViewModel.registrationFields.emailEdited)
                                if registrationViewModel.registrationFields.emailError != "" {
                                    ErrorMessageText(message: registrationViewModel.registrationFields.emailError)
                                    //.padding(.top, 8)
                                }
                            }
                            VStack {
                                CustomTextField(title: "Usuario" ,value: $registrationViewModel.registrationFields.user, edited: $registrationViewModel.registrationFields.userEdited)
                                if registrationViewModel.registrationFields.userError != "" {
                                    ErrorMessageText(message: registrationViewModel.registrationFields.userError)
                                    //.padding(.top, 18)
                                }
                            }
                            VStack {
                                CustomTextField(title: "Contraseña" ,value: $registrationViewModel.registrationFields.password, edited: $registrationViewModel.registrationFields.passwordEdited)
                                if registrationViewModel.registrationFields.passwordError != "" {
                                    ErrorMessageText(message: registrationViewModel.registrationFields.passwordError)
                                    //.padding(.top, 18)
                                }
                            }
                            HStack {
                                VStack {
                                    CustomTextField(title: "Nombre de la Tienda" ,value: $registrationViewModel.registrationFields.companyName, edited: $registrationViewModel.registrationFields.companyNameEdited)
                                    if registrationViewModel.registrationFields.companyNameError != "" {
                                        ErrorMessageText(message: registrationViewModel.registrationFields.companyNameError)
                                        //.padding(.top, 18)
                                    }
                                }
                                Button(action: {}, label: {
                                    Image("logo")
                                        .resizable()
                                        .scaledToFit()
                                        .background(Color("colorlaunchbackground"))
                                        .cornerRadius(10)
                                        .frame(width: 50, height: 50)
                                })
                            }
                            VStack {
                                CustomTextField(title: "Nombre del Dueño" ,value: $registrationViewModel.registrationFields.managerName, edited: $registrationViewModel.registrationFields.managerNameEdited)
                                if registrationViewModel.registrationFields.managerNameError != "" {
                                    ErrorMessageText(message: registrationViewModel.registrationFields.managerNameError)
                                    //.padding(.top, 18)
                                }
                            }
                            VStack {
                                CustomTextField(title: "Apellidos del Dueño" ,value: $registrationViewModel.registrationFields.managerLastName, edited: $registrationViewModel.registrationFields.managerLastNameEdited)
                                if registrationViewModel.registrationFields.managerLastNameError != "" {
                                    ErrorMessageText(message: registrationViewModel.registrationFields.managerLastNameError)
                                    //.padding(.top, 18)
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        Button(action: {
                            if registrationViewModel.registerUser() {
                                logInViewModel.checkDBIntegrity()
                            }
                        }, label: {
                            CustomButton2(text: "Registrar", backgroudColor: Color("color_accent"), minWidthC: 250)
                                .foregroundColor(Color(.black))
                        })
                    }
                    .padding(.top, 10)
                }
                .padding(.top, 1)
            })
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        CreateAccountView(isKeyboardVisible: .constant(true))
            .environmentObject(dependencies.logInViewModel)
            .environmentObject(dependencies.registrationViewModel)
    }
}
