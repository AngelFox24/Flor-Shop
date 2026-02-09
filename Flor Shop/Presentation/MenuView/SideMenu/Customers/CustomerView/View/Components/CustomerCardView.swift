import SwiftUI

struct CustomerCardView: View {
    var imageUrl: String?
    var mainText: String
    var mainIndicatorPrefix: String?
    var mainIndicator: String
    var mainIndicatorAlert: Bool
    var secondaryIndicatorSuffix: String?
    var secondaryIndicator: String?
    var secondaryIndicatorAlert: Bool
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
                        if let secondaryIndicatorUnwrap = secondaryIndicator {
                            HStack(spacing: 0){
                                Text(secondaryIndicatorUnwrap)
                                    .foregroundColor(.black)
                                    .font(.custom("Artifika-Regular", size: 16))
                                if let secondaryIndicatorSuffixUnwrap = secondaryIndicatorSuffix {
                                    Text(secondaryIndicatorSuffixUnwrap)
                                        .foregroundColor(.black)
                                        .font(.custom("Artifika-Regular", size: 12))
                                }
                            }
                            .padding(.vertical, 2)
                            .padding(.horizontal, 8)
                            .background(secondaryIndicatorAlert ? Color.red : Color.secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            Spacer()
                        }
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                VStack {
                    HStack(spacing: 0) {
                        if let mainIndicatorPrefixUnwrap = mainIndicatorPrefix {
                            Text(mainIndicatorPrefixUnwrap)
                                .foregroundColor(.black)
                                .font(.custom("Artifika-Regular", size: 14))
                        }
                        Text(mainIndicator)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 16))
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(mainIndicatorAlert ? Color.red : Color.secondary)
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
