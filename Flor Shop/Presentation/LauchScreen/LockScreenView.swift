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
                .font(.custom("Artifika-Regular", size: 18))
                .padding(.horizontal, 25)
            Button(action: {
                if let url = URL(string: "https://apps.apple.com/app/flor-shop/id6451300841") {
                    UIApplication.shared.open(url)
                }
            }) {
                CustomButton1(text: "Actualizar")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("color_background"))
        .ignoresSafeArea(.all)
    }
}

struct LockScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LockScreenView()
    }
}
