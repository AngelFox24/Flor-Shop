import SwiftUI

struct FlorShopButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Artifika-Regular", size: 22))
            .foregroundColor(Color.accent)
            .frame(width: 40, height: 40)
            .background(.white)
            .cornerRadius(25)
    }
}
struct FlorShopButtonStyleLigth: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Artifika-Regular", size: 22))
            .foregroundColor(Color.accent)
            .frame(width: 40, height: 40)
    }
}
