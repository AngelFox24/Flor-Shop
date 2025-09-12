import SwiftUI

struct FlorShopButton: View {
    let backAction: () -> Void
    var body: some View {
        Button(action: backAction) {
            HStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .padding(2)
            }
            .background(Color.launchBackground)
            .frame(width: 40, height: 40)
            .clipShape(Circle())
        }
    }
}

#Preview {
    FlorShopButton(backAction: {})
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray)
}
