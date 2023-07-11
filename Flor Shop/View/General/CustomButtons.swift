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
            .font(.custom("text_font_1", size: 20))
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
    var body: some View {
        Text(text)
            .font(.custom("text_font_1", size: 20))
            .foregroundColor(Color("color_accent"))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(.white)
            .cornerRadius(15.0)
    }
}

struct CustomButtons_Previews: PreviewProvider {
    static var previews: some View {
        CustomButton2(text: "Limpiar")
    }
}
