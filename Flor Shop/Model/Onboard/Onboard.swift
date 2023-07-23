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
    Onboard(id: UUID(), title: "Para agregar un Producto", subtitle: "Rellenamos el nombre del producto y luego pulsamos en Buscar Imagen", imageText: "View1"),
    Onboard(id: UUID(), title: "Elegimos una imagen", subtitle: "mantenemos pulsado en la imagen y copiamos", imageText: "View2"),
    Onboard(id: UUID(), title: "Volvemos a Flor Shop", subtitle: "y pulsamos en Pegar Imagen", imageText: "View3"),
    Onboard(id: UUID(), title: "Damos permiso para pegar", subtitle: "pulsamos en 'Permitir pegar'", imageText: "View4"),
    Onboard(id: UUID(), title: "Completamos los demas datos", subtitle: "Luego pulsamos en Guardar", imageText: "View5"),
    Onboard(id: UUID(), title: "Podemos deslizar hacia la derecha para agregar un producto al carrito", subtitle: "o a la izquierda para editarlo", imageText: "View6"),
    Onboard(id: UUID(), title: "En el carrito podemos aumentar la cantidad con el botón +", subtitle: "presionamos en Vender y se reducirá el stock!!!", imageText: "View7")
]
