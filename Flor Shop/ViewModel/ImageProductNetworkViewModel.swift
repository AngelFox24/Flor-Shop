//
//  ImageProductNetworkViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 19/04/23.
//

import Foundation
import SwiftUI
import Combine

class ImageProductNetworkViewModel: ObservableObject {
    
    @Published var imageProduct: Image = Image("ProductoSinNombre")
    let imagenBase:Image = Image("ProductoSinNombre")
    var suscriber = Set<AnyCancellable>()
    
    func getImage(url: URL){
        if imageProduct == imagenBase{
            URLSession.shared.dataTaskPublisher(for: url)
                .map(\.data)
                .compactMap{UIImage(data: $0)}
                .map{Image(uiImage: $0)}
                .replaceEmpty(with: Image("ProductoSinNombre"))
                .replaceError(with: Image("ProductoSinNombre"))
                .receive(on: DispatchQueue.main) //Regresamos al hilo principal, es una buena practica de Swift
                .assign(to: \.imageProduct,on: self) //Aqui asignamos luego de validar
                .store(in: &suscriber)
        }else{
        }
    }
}
