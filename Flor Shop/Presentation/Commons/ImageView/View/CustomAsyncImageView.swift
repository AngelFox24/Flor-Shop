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
            updateImage()
        })
        .onChange(of: imageUrl) { oldValue, newValue in
            updateImage(newImageUrl: newValue)
        }
    }
    func updateImage(newImageUrl: ImageUrl? = nil) {
        Task {
            self.isLoading = true
            let imageToLoad: ImageUrl? = newImageUrl ?? self.imageUrl
            if let imageNN = imageToLoad {
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
    }
}

struct CustomAsyncImageView_Previews: PreviewProvider {
    //let id: UUID? = UUID()
    static var previews: some View {
        let image = ImageUrl(
            id: UUID(
                uuidString: "D2A8F862-AEB8-4A17-B08B-2FEDDCB0B123"
            ) ?? UUID(),
            imageUrlId: UUID(),
            imageUrl: "https://falabella.scene7.com/is/image/FalabellaPE/18846925_1?wid=1500&hei=1500&qlt=70",
            imageHash: ""
        )
        CustomAsyncImageView(imageUrl: image, size: 100)
        //CustomAsyncImageView(id: .constant(id), urlProducto: .constant(nil), size: 100)
    }
}
