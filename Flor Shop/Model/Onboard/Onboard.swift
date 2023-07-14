//
//  Onboard.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/23.
//

import Foundation
import SwiftUI

struct Onboard: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let imageText: String
}

var onboardItems: [Onboard] = [
    Onboard(id: UUID(), title: "Buscamos una imagen en el Safari", subtitle: "y mantenemos pulsado la imagen", imageText: "view1"),
    Onboard(id: UUID(), title: "Copiamos la imagen", subtitle: "luego vamos a Flor Shop", imageText: "view2"),
    Onboard(id: UUID(), title: "Pegamos en el campo Imagen URL", subtitle: "Si la imagen esta bien aparecerá inmediatamente", imageText: "view3"),
    Onboard(id: UUID(), title: "Luego completamos los demás datos", subtitle: "y pulsamos Guardar", imageText: "view5"),
    Onboard(id: UUID(), title: "Podemos deslizar hacia la derecha para agregar un producto al carrito", subtitle: "o a la izquierda para editarlo", imageText: "view6"),
    Onboard(id: UUID(), title: "En el carrito podemos aumentar la cantidad con el botón +", subtitle: "presionamos en Vender y se reducirá el stock", imageText: "view7")
]
