//
//  LogInView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/08/23.
//

import SwiftUI

struct LogInView: View {
    @State var dato: String = ""
    @State var edited: Bool = false
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Text("Iniciar Sesión")
                .font(.custom("Artifika-Regular", size: 30))
                .padding(.bottom, 50)
            VStack(spacing: 40){
                CustomTextField(title: "Usuario o Correo" ,value: $dato, edited: $edited, keyboardType: .default)
                CustomTextField(title: "Contraseña" ,value: $dato, edited: $edited, keyboardType: .default)
            }
            .padding(.horizontal, 30)
            VStack(spacing: 30) {
                Button(action: {}, label: {
                    CustomButton2(text: "Ingresar", backgroudColor: Color("color_background"), minWidthC: 250)
                        .foregroundColor(Color(.black))
                })
                Color(.gray)
                    .frame(width: 280, height: 2)
                Button(action: {}, label: {
                    CustomButton2(text: "Continuar con Google", backgroudColor: Color("color_primary"), minWidthC: 250)
                        .foregroundColor(Color(.black))
                })
                Button(action: {}, label: {
                    CustomButton2(text: "Continuar con Apple", backgroudColor: Color("color_primary"), minWidthC: 250)
                        .foregroundColor(Color(.black))
                })
            }
            .padding(.top, 30)
            Spacer()
        }
        .background(Color("color_accent"))
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
