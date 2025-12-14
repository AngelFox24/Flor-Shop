import SwiftUI
import Kingfisher

struct CustomAsyncImageView: View {
    let imageUrlString: String?
    let size: CGFloat
    @State private var didFail = false
    private let processor = DownsamplingImageProcessor(size: CGSize(width: 200, height: 200))
    private let imageUrl: URL?
    init(
        imageUrlString: String?,
        size: CGFloat
    ) {
        self.imageUrlString = imageUrlString
        self.size = size
        if let imageUrlString {
            self.imageUrl = URL(string: imageUrlString)
        } else {
            self.imageUrl = nil
        }
    }
    var body: some View {
        HStack {
            if didFail {
                CardViewPlaceHolder2(size: size)
            } else {
                KFImage(imageUrl)
                    .setProcessor(processor)
                    .resizable()
                    .roundCorner(radius: .point(15))
                    .serialize(as: .PNG)
                    .cancelOnDisappear(true)
                    .onFailure { _ in
                        didFail = true
                    }
                    .placeholder {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(width: size, height: size)
                            .cornerRadius(15.0)
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
            }
        }
    }
}

struct CustomAsyncImageView_Previews: PreviewProvider {
    static var previews: some View {
        CustomAsyncImageView(imageUrlString: "https://falabella.scene7.com/is/image/FalabellaPE/18846925_1?wid=1500&hei=1500&qlt=70", size: 100)
    }
}
