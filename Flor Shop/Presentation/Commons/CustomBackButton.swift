//
//  CustomBackButton.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/08/23.
//

import SwiftUI

struct CustomBackButton: View {
    var tittle: String = "Back"
    var color: Color = Color(.blue)
    var body: some View {
        HStack {
            Image(systemName: "arrow.left") // Cambia el icono si lo deseas
            Text(tittle) // Cambia el texto del botón
        }
        .foregroundColor(color)
    }
}

struct CustomBackButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomBackButton()
    }
}
