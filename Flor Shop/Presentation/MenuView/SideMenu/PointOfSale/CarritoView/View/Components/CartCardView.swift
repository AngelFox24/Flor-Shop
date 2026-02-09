import SwiftUI

struct CartCardView: View {
    let cartDetailId: UUID
    let imageUrl: String?
    let productName: String
    var mainIndicatorPrefix: String
    var mainIndicator: String
    var secondaryIndicatorSuffix: String
    var secondaryIndicator: String
    let decreceProductAmount: (UUID) -> Void
    var increaceProductAmount: (UUID) -> Void
    let size: CGFloat = 80
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                CustomAsyncImageView(imageUrlString: imageUrl, size: size)
                VStack {
                    HStack {
                        Text(productName)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 16))
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .padding(.top, 6)
                    HStack {
                        Button(action: {}, label: {
                            Image(systemName: "minus")
                                .resizable()
                                .font(.headline)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                                .padding(8)
                                .foregroundColor(Color.accentColor)
                                .background(Color.secondary)
                                .clipShape(Circle())
                        })
                        .highPriorityGesture(TapGesture().onEnded {
                            decreceProductAmount(cartDetailId)
                        })
                        HStack(spacing: 0) { // Cantidad Producto
                            Text(secondaryIndicator)
                                .foregroundColor(.black)
                                .font(.custom("Artifika-Regular", size: 16))
                            Text(secondaryIndicatorSuffix)
                                .foregroundColor(.black)
                                .font(.custom("Artifika-Regular", size: 12))
                        }
                        .padding(.vertical, 2)
                        .padding(.horizontal, 10)
                        .background(Color.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        Button(action: {}, label: {
                            Image(systemName: "plus")
                                .resizable()
                                .font(.headline)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                                .padding(8)
                                .foregroundColor(Color.accentColor)
                                .background(Color.secondary)
                                .clipShape(Circle())
                        })
                        .highPriorityGesture(TapGesture().onEnded {
                            increaceProductAmount(cartDetailId)
                        })
                        Spacer()
                    }
                }
                .padding(.bottom, 6)
                VStack {
                    HStack(spacing: 0) {
                        Text(mainIndicatorPrefix)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 14))
                        Text(mainIndicator)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 16))
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .foregroundColor(.black)
                    .background(Color.secondary)
                    .cornerRadius(20)
                }
                .padding(.horizontal, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: size)
            .background(.white)
        }
        .cornerRadius(15)
    }
}

#Preview {
    VStack {
        Spacer()
        CartCardView(
            cartDetailId: UUID(),
            imageUrl: "https://img.freepik.com/vector-gratis/comida-cesta-compras-ilustracion_98292-3782.jpg?semt=ais_hybrid&w=740&q=80",
            productName: "Producto Test",
            mainIndicatorPrefix: "S/. ",
            mainIndicator: "34.21",
            secondaryIndicatorSuffix: " Kg",
            secondaryIndicator: "56",
            decreceProductAmount: {_ in},
            increaceProductAmount: {_ in}
        )
        Spacer()
    }
    .padding(.horizontal, 10)
    .background(Color.background)
}
