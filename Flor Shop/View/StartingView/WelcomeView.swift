//
//  WelcomeView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/08/23.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var isKeyboardVisible: Bool
    @EnvironmentObject var navManager: NavManager
    var body: some View {
        VStack {
            Spacer()
            Image("logo")
                .resizable()
                .scaledToFit()
                .background(Color("colorlaunchbackground"))
                .cornerRadius(30)
                .frame(width: 200, height: 200)
            Spacer()
            VStack(spacing: 20) {
                Text("Hola! Bienvenido a Flor Shop")
                    .font(.custom("Artifika-Regular", size: 30))
                Text("Administra tu negocio fácilmente, Flor Shop te ayudará a gestionar tus recursos y ventas.")
                    .font(.custom("Artifika-Regular", size: 20))
                    .padding(.horizontal, 15)
            }
            .frame(maxWidth: .infinity)
            Spacer()
            VStack(spacing: 30) {
                Button(action: {
                    print("1")
                    navManager.goToLoginView()
                }, label: {
                    CustomButton2(text: "Tengo una cuenta", backgroudColor: Color("color_accent"), minWidthC: 250)
                        .foregroundColor(Color(.black))
                })
                Button(action: {
                    print("2")
                    navManager.goToRegistrationView()
                }, label: {
                    CustomButton2(text: "Crear Cuenta", backgroudColor: Color("color_background"), minWidthC: 250)
                        .foregroundColor(Color(.black))
                })
            }
            .navigationDestination(for: NavPathsEnum.self, destination: { view in
                if view == .loginView {
                    let _ = print("3")
                    LogInView(isKeyboardVisible: $isKeyboardVisible)
                } else if view == .registrationView {
                    let _ = print("4")
                    CreateAccountView(isKeyboardVisible: $isKeyboardVisible)
                }
            })
            Spacer()
        }
        .background(Color("color_primary"))
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        let navManager = NavManager()
        WelcomeView(isKeyboardVisible: .constant(true))
            .environmentObject(navManager)
    }
}
