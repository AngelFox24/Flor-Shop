import SwiftUI

struct LogoToolBar: ToolbarContent {
    let action: () -> Void
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: action) {
                Image("logito")
                    .resizable()
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
            }
            .buttonStyle(.borderless)
            .offset(x: -4)
        }
        .sharedBackgroundVisibility(.hidden)
    }
}

struct TittleBarTest: View {
    var body: some View {
        Text("Hello, World!")
            .toolbar {
                LogoToolBar(action: {})
            }
    }
}

#Preview {
    TittleBarTest()
}
