//
//  CustomButtons.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 9/06/23.
//

import SwiftUI

struct CustomButton1: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.custom("Artifika-Regular", size: 20))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(Color("color_accent"))
            .cornerRadius(15.0)
    }
}

struct CustomButton2: View {
    let text: String
    var backgroudColor: Color = Color("color_accent")
    var minWidthC: CGFloat = 200
    var body: some View {
        Text(text)
            .font(.custom("Artifika-Regular", size: 20))
            .frame(minWidth: minWidthC)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(backgroudColor)
            .cornerRadius(15.0)
    }
}

struct CustomButtons_Previews: PreviewProvider {
    static var previews: some View {
        CustomButton2(text: "Limpiar")
    }
}