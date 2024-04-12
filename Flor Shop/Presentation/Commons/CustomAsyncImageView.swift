//
//  CustomAsyncImageView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 10/06/23.
//

import SwiftUI

struct CustomAsyncImageView: View {
    let id: UUID?
    let urlProducto: String?
    let size: CGFloat
    @StateObject var imageViewModel = ImageViewModel()
    var body: some View {
        HStack {
            if let imageC = imageViewModel.image {
                imageC
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .cornerRadius(15.0)
            } else {
                CardViewPlaceHolder2(size: size)
            }
        }
        .onAppear(perform: {
            Task {
                print("Se carga task: \(id)")
                if let idNN = id {
                    print("Se carga NN: \(idNN)")
                    self.imageViewModel.isLoading = true
                    await imageViewModel.loadImage(id: idNN, url: urlProducto)
                    self.imageViewModel.isLoading = false
                }
            }
        })
    }
}

struct CustomAsyncImageView_Previews: PreviewProvider {
    //let id: UUID? = UUID()
    static var previews: some View {
        CustomAsyncImageView(id: UUID(uuidString: "D2A8F862-AEB8-4A17-B08B-2FEDDCB0B123") ?? UUID(), urlProducto: "https://falabella.scene7.com/is/image/FalabellaPE/18846925_1?wid=1500&hei=1500&qlt=70", size: 100)
        //CustomAsyncImageView(id: .constant(id), urlProducto: .constant(nil), size: 100)
    }
}
