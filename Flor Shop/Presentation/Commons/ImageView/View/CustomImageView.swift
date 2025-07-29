import SwiftUI
import PhotosUI

struct CustomImageView: View {
    @Binding var uiImage: UIImage?
    let size: CGFloat
    let searchFromInternet: (() -> Void)?
    let searchFromGallery: () -> Void
    let takePhoto: () -> Void
    var body: some View {
        Menu {
            if let searchAction = searchFromInternet {
                Button(action: {
                    searchAction()
                }) {
                    Label("Buscar en Internet", systemImage: "globe")
                }
            }
            Button(action: {
                searchFromGallery()
            }) {
                Label("Buscar en Galería", systemImage: "photo.on.rectangle.angled")
            }
            Button(action: {
                takePhoto()
            }) {
                Label("Tomar Foto", systemImage: "camera")
            }
        } label: {
            if let imageC = uiImage {
                Image(uiImage: imageC)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .cornerRadius(15.0)
            } else {
                CardViewPlaceHolder2(size: size)
            }
        }
    }
}
func doNothing() {
    
}

#Preview {
    VStack {
        CustomImageView(
            uiImage: .constant(nil),
            size: 100,
            searchFromInternet: doNothing,
            searchFromGallery: doNothing,
            takePhoto: doNothing
        )
        Spacer()
    }
}
