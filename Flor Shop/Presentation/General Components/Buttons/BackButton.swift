import SwiftUI

struct BackButton: View {
    let backAction: () -> Void
    var body: some View {
        Image(systemName: "chevron.backward")
            .modifier(FlorShopButtonStyle())
            .onTapGesture { backAction() }
    }
}

#Preview {
    BackButton(backAction: {})
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray)
}
