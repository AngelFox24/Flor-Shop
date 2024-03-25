//
//  CustomAsyncImageView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 10/06/23.
//

import SwiftUI

struct CustomAsyncImageView: View {
    let id: UUID
    let urlProducto: String
    let size: CGFloat
    @ObservedObject var imageProductNetwork = ImageProductNetworkViewModel()
    init(id: UUID, urlProducto: String, size: CGFloat, imageProductNetwork: ImageProductNetworkViewModel = ImageProductNetworkViewModel()) {
        self.id = id
        self.urlProducto = urlProducto
        self.size = size
        self.imageProductNetwork = imageProductNetwork
        imageProductNetwork.getImage(id: id, url: (((URL(string: urlProducto ) ?? URL(string: "https://falabella.scene7.com/is/image/FalabellaPE/gsc_117581885_1813935_1?wid=1500&hei=1500&qlt=70"))!)))
    }
    var body: some View {
        HStack {
            if let imageC = imageProductNetwork.imageProduct {
                imageC
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .cornerRadius(15.0)
            } else {
                Image("ProductoSinNombre")
                    .resizable()
                    .frame(width: size, height: size)
                    .cornerRadius(15.0)
            }
        }
    }
}

struct CustomAsyncImageView_Previews: PreviewProvider {
    static var previews: some View {
        CustomAsyncImageView(id: UUID(uuidString: "3062F3B7-14C7-4314-B342-1EC912EBD925") ?? UUID(), urlProducto: "https://s7d2.scene7.com/is/image/TottusPE/42762662_0?wid=136&hei=136&qlt=70", size: 100)
    }
}
