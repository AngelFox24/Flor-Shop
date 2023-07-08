//
//  LockScreenView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 8/07/23.
//

import SwiftUI

struct LockScreenView: View {
    var body: some View {
        VStack {
            Image("groundhog-cry")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
            Text("Versión desactualizada, vamos a la tienda a descargar la ultima versión")
                .padding(.horizontal,20)
            /*
            Button(action: {
                //selectedTab = .magnifyingglass
            }) {
                CustomButton1(text: "Ir a Productos")
            }
            */
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .background(Color("color_background"))
        .ignoresSafeArea(.all)
    }
}

struct LockScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LockScreenView()
    }
}
