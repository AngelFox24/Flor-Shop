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
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
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

struct CustomButton3: View {
    var simbol: String = "chevron.backward"
    var body: some View {
        Image(systemName: simbol)
            .font(.custom("Artifika-Regular", size: 22))
            .foregroundColor(Color("color_accent"))
            .frame(width: 40, height: 40)
            .background(.white)
            .cornerRadius(15)
    }
}

struct CustomButton4: View {
    var simbol: String = "chevron.backward"
    var body: some View {
        Image(systemName: simbol)
            .font(.custom("Artifika-Regular", size: 30))
            .foregroundColor(Color("color_background"))
            .frame(width: 50, height: 50)
            .background(Color("color_accent"))
            .cornerRadius(30)
    }
}

struct CustomButtons_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 5, content: {
            CustomButton1(text: "Limpiar")
            CustomButton2(text: "Limpiar")
            CustomButton3(simbol: "chevron.backward")
            CustomButton4(simbol: "plus")
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray)
    }
}
