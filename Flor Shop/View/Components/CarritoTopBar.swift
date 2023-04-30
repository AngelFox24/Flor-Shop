//
//  CarritoTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/04/23.
//

import SwiftUI

struct CarritoTopBar: View {
    @Binding var totalText:Double
    var body: some View {
        HStack{
            Text("S/. \(totalText)")
                .font(.title2)
            Spacer()
            Button(action: { }) {
                Text("Vender")
                    .font(.title)
                    .foregroundColor(Color("color_background"))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal,15)
            .padding(.vertical,10)
            .background(Color("color_secondary"))
            .cornerRadius(15.0)
            .font(.title)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom,10)
        .padding(.horizontal,20)
        .background(Color("color_primary"))
    }
}

struct CarritoTopBar_Previews: PreviewProvider {
    static var previews: some View {
        CarritoTopBar(totalText: .constant(45.84))
    }
}
