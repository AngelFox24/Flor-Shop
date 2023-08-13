//
//  CreateAccountView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/08/23.
//

import SwiftUI

struct CreateAccountView: View {
    @State var dato: String = "Prueba"
    @State var edited: Bool = false
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Text("Crea una Cuenta")
                .font(.custom("Artifika-Regular", size: 30))
                //.padding(.bottom, 50)
            Spacer()
            VStack(spacing: 50){
                CustomTextField(title: "Correo" ,value: $dato, edited: $edited)
                CustomTextField(title: "Usuario" ,value: $dato, edited: $edited)
                CustomTextField(title: "Contraseña" ,value: $dato, edited: $edited)
                HStack {
                    CustomTextField(title: "Nombre de la Tienda" ,value: $dato, edited: $edited)
                    Button(action: {}, label: {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .background(Color("colorlaunchbackground"))
                            .cornerRadius(10)
                            .frame(width: 50, height: 50)
                    })
                }
                CustomTextField(title: "Nombre del Dueño" ,value: $dato, edited: $edited)
            }
            .padding(.horizontal, 30)
            Spacer()
            Button(action: {}, label: {
                CustomButton2(text: "Registrar", backgroudColor: Color("color_background"), minWidthC: 250)
                    .foregroundColor(Color(.black))
            })
            Spacer()
        }
        .background(Color("color_accent"))
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView()
    }
}
