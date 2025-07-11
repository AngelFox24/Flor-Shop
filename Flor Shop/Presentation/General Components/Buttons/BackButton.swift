import SwiftUI

struct BackButton: View {
    @Environment(Router.self) private var router
    var body: some View {
        Image(systemName: "chevron.backward")
            .modifier(FlorShopButtonStyle())
            .onTapGesture { router.goBack() }
    }
}

#Preview {
    @Previewable @State var router = Router()
    BackButton()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray)
        .environment(router)
}
