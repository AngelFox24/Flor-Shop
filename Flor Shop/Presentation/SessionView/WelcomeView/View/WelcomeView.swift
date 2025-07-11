//
//  WelcomeView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/08/23.
//

import SwiftUI
import AppRouter
    
struct WelcomeView: View {
    @Environment(Router.self) private var router
    var body: some View {
        VStack {
            Spacer()
            Image("logo")
                .resizable()
                .scaledToFit()
                .background(Color.launchBackground)
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
                    router.navigateTo(.logInFlow(.loginView))
                }, label: {
                    CustomButton2(text: "Tengo una cuenta", backgroudColor: Color("color_accent"), minWidthC: 250)
                        .foregroundColor(Color(.black))
                })
                Button(action: {
                    router.navigateTo(.logInFlow(.registrationView))
                }, label: {
                    CustomButton2(text: "Crear Cuenta", backgroudColor: Color("color_background"), minWidthC: 250)
                        .foregroundColor(Color(.black))
                })
            }
            Spacer()
        }
        .background(Color("color_primary"))
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
