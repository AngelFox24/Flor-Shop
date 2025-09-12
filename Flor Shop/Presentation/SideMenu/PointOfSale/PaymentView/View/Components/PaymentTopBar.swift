import SwiftUI

struct PaymentTopBar: View {
    let backAction: () -> Void
    let registerSale: () -> Void
    var body: some View {
        HStack {
            BackButton(backAction: backAction)
            Spacer()
            Button(action: registerSale) {
                CustomButton1(text: "Finalizar")
            }
        }
    }
}

#Preview {
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    PaymentTopBar(backAction: {}, registerSale: {})
        .environment(mainRouter)
}
