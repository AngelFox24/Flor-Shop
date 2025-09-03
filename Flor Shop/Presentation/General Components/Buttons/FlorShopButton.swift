import SwiftUI

struct FlorShopButton: View {
    let backAction: () -> Void
    var body: some View {
        Button(action: backAction) {
            HStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
            }
            .background(Color.launchBackground)
            .cornerRadius(10)
            .frame(width: 40, height: 40)
        }
    }
}

#Preview {
    FlorShopButton(backAction: {})
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray)
}
