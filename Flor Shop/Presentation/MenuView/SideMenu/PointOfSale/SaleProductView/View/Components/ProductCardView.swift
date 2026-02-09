import SwiftUI

struct ProductCardView: View {
    var imageUrl: String?
    var mainText: String
    var mainIndicatorPrefix: String
    var mainIndicator: String
    var secondaryIndicatorSuffix: String
    var secondaryIndicator: String
    let size: CGFloat = 80
    var body: some View {
        VStack{
            HStack(spacing: 0, content: {
                CustomAsyncImageView(imageUrlString: imageUrl, size: size)
                VStack(spacing: 2) {
                    HStack {
                        Text(mainText)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 16))
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                    HStack {
                        HStack(spacing: 0){
                            Text(secondaryIndicator)
                                .foregroundColor(.black)
                                .font(.custom("Artifika-Regular", size: 16))
                            Text(secondaryIndicatorSuffix)
                                .foregroundColor(.black)
                                .font(.custom("Artifika-Regular", size: 12))
                        }
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .background(Color.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        Spacer()
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
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
                    .background(Color.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(.horizontal, 10)
            })
            .frame(maxWidth: .infinity, maxHeight: size)
            .background(.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    VStack {
        Spacer()
        ProductCardView(
            imageUrl: "https://img.freepik.com/vector-gratis/comida-cesta-compras-ilustracion_98292-3782.jpg?semt=ais_hybrid&w=740&q=80",
            mainText: "Nombre test",
            mainIndicatorPrefix: "S/. ",
            mainIndicator: "45.89",
            secondaryIndicatorSuffix: " u",
            secondaryIndicator: "5"
        )
        Spacer()
    }
    .background(Color.background)
}
