//
//  CustomAsyncImageView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 10/06/23.
//

import SwiftUI

struct CustomAsyncImageView: View {
    let imageUrl: ImageUrl?
    let size: CGFloat
    @State var isLoading: Bool = true
    @State var image: Image?
    var body: some View {
        HStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: size, height: size)
                    .cornerRadius(15.0)
            } 
            else {
                if let imageC = image {
                    imageC
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size, height: size)
                        .cornerRadius(15.0)
                } else {
                    CardViewPlaceHolder2(size: size)
                }
            }
        }
        .onAppear(perform: {
            Task {
                self.isLoading = true
//                try? await Task.sleep(nanoseconds: 2_000_000_000)
                if let imageNN = imageUrl {
                    let imageR = try? await LocalImageManagerImpl.loadImage(image: imageNN)
                    if let uiImage = imageR {
                        await MainActor.run {
                            self.image = Image(uiImage: uiImage)
                        }
                    }
                } else {
                    print("Imagen Nula")
                }
                self.isLoading = false
            }
        })
    }
}

struct CustomAsyncImageView_Previews: PreviewProvider {
    //let id: UUID? = UUID()
    static var previews: some View {
        let image = ImageUrl(id: UUID(uuidString: "D2A8F862-AEB8-4A17-B08B-2FEDDCB0B123") ?? UUID(), imageUrl: "https://falabella.scene7.com/is/image/FalabellaPE/18846925_1?wid=1500&hei=1500&qlt=70", imageHash: "", createdAt: Date(), updatedAt: Date())
        CustomAsyncImageView(imageUrl: image, size: 100)
        //CustomAsyncImageView(id: .constant(id), urlProducto: .constant(nil), size: 100)
    }
}
