import SwiftUI

struct CustomHideKeyboard: View {
    var action: () -> Void = {}
    var body: some View {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        action()
                    }, label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.system(size: 20))
                            .foregroundColor(Color.accent)
                            .padding(.trailing, 20)
                            .padding(.vertical, 10)
                    })
                }
                .background(Color.primary)
            }
    }
}

#Preview {
    CustomHideKeyboard()
}
