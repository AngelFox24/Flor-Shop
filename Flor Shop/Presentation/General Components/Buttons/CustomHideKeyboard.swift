import SwiftUI

struct CustomHideKeyboard: View {
    var action: () -> Void = {}
    var body: some View {
        HStack {
            Spacer()
            Button(action: action) {
                Image(systemName: "keyboard.chevron.compact.down")
                    .foregroundColor(Color.accentColor)
                    .padding(.horizontal, 2)
            }
        }
        .padding(.horizontal, 2)
    }
}

#Preview {
    CustomHideKeyboard()
}
