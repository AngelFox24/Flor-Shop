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
    @State var isLoading: Bool = true
//    @StateObject var imageViewModel = ImageViewModel()
    var body: some View {
        HStack {
            if isLoading {
                //TODO: Falta validar si consume muchos recursos esta animacion
                LoadingFotoView(size: size)
                    .cornerRadius(15.0)
            } 
//            else {
//                if let imageC = imageViewModel.image {
//                    imageC
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: size, height: size)
//                        .cornerRadius(15.0)
//                } else {
//                    CardViewPlaceHolder2(size: size)
//                }
//            }
        }
//        .onAppear(perform: {
//            Task {
//                self.isLoading = true
//                if let idNN = id {
//                    await imageViewModel.loadImage(id: idNN, url: urlProducto)
//                }
//                self.isLoading = false
//            }
//        })
    }
}

struct CustomAsyncImageView_Previews: PreviewProvider {
    //let id: UUID? = UUID()
    static var previews: some View {
        CustomAsyncImageView(id: UUID(uuidString: "D2A8F862-AEB8-4A17-B08B-2FEDDCB0B123") ?? UUID(), urlProducto: "https://falabella.scene7.com/is/image/FalabellaPE/18846925_1?wid=1500&hei=1500&qlt=70", size: 100)
        //CustomAsyncImageView(id: .constant(id), urlProducto: .constant(nil), size: 100)
    }
}
