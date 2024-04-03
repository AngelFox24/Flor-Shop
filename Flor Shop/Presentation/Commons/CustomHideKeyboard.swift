//
//  CustomHideKeyboard.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 6/06/23.
//

import SwiftUI

struct CustomHideKeyboard: View {
    var body: some View {
        ZStack {
            VStack {
                //Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }, label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.system(size: 30))
                            .foregroundColor(Color("color_accent"))
                            .padding(.trailing, 50)
                            .padding(.vertical, 10)
                    })
                }
                .background(Color("color_primary"))
            }
        }
    }
}

struct CustomHideKeyboard_Previews: PreviewProvider {
    static var previews: some View {
        CustomHideKeyboard()
    }
}
