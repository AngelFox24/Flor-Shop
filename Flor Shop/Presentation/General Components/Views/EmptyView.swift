//
//  EmptyView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 10/09/2025.
//

import SwiftUI

struct EmptyView: View {
    let imageName: String
    let text: String
    let textButton: String
    let pushDestination: PushDestination
    init(
        imageName: String = "groundhog_finding",
        text: String = "Agreguemos algo",
        textButton: String = "Agregar",
        pushDestination: PushDestination
    ) {
        self.imageName = imageName
        self.text = text
        self.textButton = textButton
        self.pushDestination = pushDestination
    }
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                Text(text)
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .font(.custom("Artifika-Regular", size: 18))
                NavigationButton(push: pushDestination) {
                    CustomButton1(text: textButton)
                }
                Spacer()
            }
            Spacer()
        }
    }
}

#Preview {
    @Previewable @State var router = FlorShopRouter.previewRouter()
    EmptyView(pushDestination: .addCustomer)
        .environment(router)
}
