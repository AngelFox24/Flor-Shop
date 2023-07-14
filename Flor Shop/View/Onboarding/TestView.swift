//
//  TestView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/23.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        HStack {
            VStack(spacing: 0) {
                Text("Buscamos una imagen en el Safari")
                Text("y mantenemos pulsado la imagen")
                Image("view1")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.all)
        .background(Color("color_primary"))
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
