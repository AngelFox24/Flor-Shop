//
//  CardViewTipe2.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 26/09/23.
//

import SwiftUI

struct CardViewTipe2: View {
    var image: ImageUrl
    var topStatusColor: Color?
    var topStatus: String?
    var mainText: String
    var mainIndicatorPrefix: String?
    var mainIndicator: String
    var mainIndicatorAlert: Bool
    var secondaryIndicatorSuffix: String?
    var secondaryIndicator: String?
    var secondaryIndicatorAlert: Bool
    let size: CGFloat
    var body: some View {
        VStack {
            HStack {
                CustomAsyncImageView(id: image.id, urlProducto: image.imageUrl, size: size)
                VStack(spacing: 2) {
                    if let topStatusUnwrap = topStatus, let topStatusColorUnwrap = topStatusColor {
                        HStack{
                            topStatusColorUnwrap
                                .frame(width: 10, height: 10)
                                .cornerRadius(15)
                            Text(topStatusUnwrap)
                                .foregroundColor(.black)
                                .font(.custom("Artifika-Regular", size: 9))
                            Spacer()
                        }
                    }
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
                            .padding(.horizontal, 10)
                            .background(secondaryIndicatorAlert ? Color(.red) : Color("color_secondary"))
                            .cornerRadius(20)
                            Spacer()
                        }
                    }
                }
                .padding(.vertical, 6)
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
                    .background(mainIndicatorAlert ? Color(.red) : Color("color_secondary"))
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

struct CardViewTipe2_Previews: PreviewProvider {
    static var previews: some View {
        CardViewTipe2(image: ImageUrl.getDummyImage(), topStatusColor: Color.red, topStatus: "Manager", mainText: "Carlos", mainIndicatorPrefix: "S/. ", mainIndicator: "23.00", mainIndicatorAlert: false, secondaryIndicatorSuffix: " u", secondaryIndicator: "9", secondaryIndicatorAlert: true, size: 80)
            .frame(maxHeight: .infinity)
            .background(Color.gray)
    }
}
