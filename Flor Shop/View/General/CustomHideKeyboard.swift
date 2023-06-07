//
//  CustomHideKeyboard.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 6/06/23.
//

import SwiftUI

struct CustomHideKeyboard: View {
    var body: some View {
        HStack{
            
            Spacer()
            
            Button(action: {
                print("Se presiono el boton de desaparecer")
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }) {
                Image(systemName: "keyboard.chevron.compact.down")
                    .font(.system(size: 30))
                    .foregroundColor(Color("color_secondary"))
            }
            .padding(.trailing,50)
        }
        .frame(width: nil, height: 60)
        .background(Color("color_primary"))
    }
}

struct CustomHideKeyboard_Previews: PreviewProvider {
    static var previews: some View {
        CustomHideKeyboard()
    }
}
